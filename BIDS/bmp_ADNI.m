function DICOM2BIDS = bmp_ADNI (operation_mode, varargin)
%
% DESCRIPTION
% ====================================================================================
%
%   bmp_ADNI aims to generate DICOM-to-BIDS mappings for ADNI dataset. It is called
%   by bmp_DICOMtoBIDSmapper if predefined dataset 'ADNI' is specified. Results of
%   bmp_ADNI can be directly used in bmp_BIDSgenerator. Details on the structure of
%   DICOM-to-BIDS mappings can be found in the header of bmp_BIDSgenerator.m, or by
%   typing 'help bmp_BIDSgenerator' in MATLAB Command Window.
%
%   Note that since ADNI dataset has multiple sessions (i.e., timepoints) and subject
%   ID and scan date need to be used to identify session label, we specify ADNI
%   DICOM-to-BIDS mappings in individual-level.
%
%
% EVIDENCE TO CREATE MAPPINGS
% ====================================================================================
%
%   ASL
%
%     For ADNI ASL data, we considered 5 CSV files of study data downloaded from 
%     https://ida.loni.usc.edu/pages/access/studyData.jsp?project=ADNI
%
%       - MRILIST.csv
%       - UCSFASLQC.csv
%       - UCSFASLFS_11_02_15_V2.csv
%       - UCSFASLFSCBF_08_17_22.csv
%       - ADNIMERGE.csv
%
%     Refer to /path/to/BrainMRIpipelines/BIDS/ADNI_study_data/bmp_procADNIstudyData.m.
%
%
% ARGUMENTS
% ====================================================================================
%
%   bmp_ADNI can be ran in two modes:
%
%     'create'   mode : This mode is used to generate DICOM-to-BIDS mappings, and save
%                       the mappings in a .mat file. In this mode, pass 'create'
%                       to the argument 'operation_mode', and /path/to/save/XXX.mat
%                       to varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be used.
%
%     'retrieve' mode : This mode load the previously created .mat file to retrieve the 
%                       predefiend mappings. In this mode, pass 'retrieve'
%                       to the argument 'operation_mode', and /path/to/retrieve/XXX.mat 
%                       to varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be used.
%
%
% SUPPORTED MODALITIES
% ====================================================================================
%
%   - asl
%
%
% HISTORY
% ====================================================================================
%
%   05 December 2022 - first version.
%
%
% NEED TO INVESTIGATE
% ====================================================================================
%
% SEQUENCE :
%
%   - Cerebral Blood Flow
%   - MoCoSeries
%   - ax
%   - cor
%   - cor mpr

	BMP_PATH = getenv ('BMP_PATH');



	% possible keywords in DICOM sequence name for each modality in ADNI
	possibleASLkeywords = 	{
							'ASL'
							'cerebral blood flow'
							'perfusion'
							};

	possibleT1keywords = 	{
							'MPRAGE'
							'T1'
							'IR-SPGR'
							'IR-FSPGR'
							'MP-RAGE'
							'MP RAGE'
							};




	switch operation_mode

		case 'create'

			if nargin == 2 && endsWith(varargin{1},'.mat')
				output = varargin{1};
			else
				output = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''create'' mode. Will save DICOM2BIDS mapping to %s.\n',mfilename,output);

			fprintf ('%s : Loading bmp_ADNI_ASL_forDicom2BidsMapping.mat ... ', mfilename);

			ADNI_mat = load (fullfile (BMP_PATH, 'BIDS', 'ADNI_study_data', 'bmp_ADNI_forDicom2BidsMapping.mat'));

			fprintf ('DONE!\n', mfilename);

			ADNI = ADNI_mat.ADNI_forDicom2BidsMapping;
			ADNI_uniqueSID = unique(ADNI.SID);

			fprintf ('%s : Start to create DICOM2BIDS mapping.\n', mfilename);

			


			for i = 1 : size (ADNI_uniqueSID,1)

				fprintf ('%s : Processing subject ID (SID) %s.\n', mfilename, ADNI_uniqueSID{i});

				DICOM2BIDS(i).subject = ['sub-ADNI' erase(ADNI_uniqueSID{i},'_')];

				sid_data = ADNI(find(strcmp(ADNI.SID, ADNI_uniqueSID{i})),:);

				fprintf ('%s : Subject %s has %d entries in bmp_ADNI_forDicom2BidsMapping.mat.\n', mfilename, ADNI_uniqueSID{i}, size(sid_data,1));

				for j = 1 : size (sid_data, 1)



					% +++++++++++++++++++++++++
					%            ASL
					% +++++++++++++++++++++++++


					  % 28×1 cell array

					  %   {'ASL'                                            }
					  %   {'ASL PERF'                                       }
					  %   {'ASL PERFUSION'                                  }
					  %   {'ASL PERFUSION   INSTRUCT PT TO KEEP EYES OPENED'}
					  %   {'ASL PERFUSION EYE OPEN'                         }
					  %   {'ASL PERFUSION(EYES OPEN)'                       }
					  %   {'ASL PERFUSION-EYES OPEN'                        }
					  %   {'ASL PERFUSION____EYES_OPEN'                     }
					  %   {'ASL PERFUSION_eyes open'                        }
					  %   {'ASL_PERFUSION'                                  }
					  %   {'ASL_PERFUSION_NO ANGLE='                        }
					  %   {'Ax 3D pCASL (Eyes Open)'                        }
					  %   {'Axial 2D PASL'                                  }
					  %   {'Axial 2D PASL (EYES OPEN)'                      }
					  %   {'Axial 2D PASL 0 angle L'                        }
					  %   {'Axial 2D PASL straight no ASL'                  }
					  %   {'Axial 3D PASL (Eyes Open)'                      }
					  %   {'Axial 3D PASL (Eyes Open)    straight no angle' }
					  %   {'Axial 3D PASL (Eyes Open) REPEAT'               }
					  %   {'Axial 3D pCASL'                                 }
					  %   {'Axial 3D pCASL (Eyes Open)'                     }
					  %   {'Axial_3D_pCASL_Eyes_Open'                       }
					  %   {'Cerebral Blood Flow'                            }
					  %   {'Perfusion_Weighted'                             }
					  %   {'SOURCE - Axial 2D PASL'                         }
					  %   {'WIP SOURCE - Axial 2D PASL'                     }
					  %   {'WIP SOURCE - Axial 3D pCASL (Eyes Open)'        }
					  %   {'tgse_pcasl_PLD2000'                             }




					if contains (sid_data.SEQUENCE{j}, possibleASLkeywords, 'IgnoreCase', true)

						DICOM2BIDS(i).perf.asl.DICOM.SeriesDescription = sid_data.SEQUENCE{j};
						DICOM2BIDS(i).perf.asl.DICOM.PatientID         = sid_data.SID{j};
						DICOM2BIDS(i).perf.asl.DICOM.StudyDate         = erase(char(sid_data.SCANDATE(j)),'-');

						switch sid_data.SEQUENCE{j}

							case 'Axial 3D PASL (Eyes Open)'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpasl';
							case 'Axial 3D PASL (Eyes Open)    straight no angle'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpasl';
							case 'Axial 3D PASL (Eyes Open) REPEAT'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpasl'; 	% this happened once for 036_S_6316
																							% on 2019-08-13. However, we cannot
																							% find another ASL on the same day
																							% therefore, we are not assigning
																							% 'run' entity although it said
																							% 'REPEAT'.

							case 'Ax 3D pCASL (Eyes Open)'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpcasl';
							case 'Axial 3D pCASL'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpcasl';
							case 'Axial 3D pCASL (Eyes Open)'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpcasl';
							case 'Axial_3D_pCASL_Eyes_Open'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpcasl';
							case 'WIP SOURCE - Axial 3D pCASL (Eyes Open)'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial3Dpcasl';

							case 'Axial 2D PASL'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial2Dpasl';
							case 'Axial 2D PASL (EYES OPEN)'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial2Dpasl';
							case 'Axial 2D PASL 0 angle L'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial2Dpasl';
							case 'Axial 2D PASL straight no ASL'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial2Dpasl';
						    case 'SOURCE - Axial 2D PASL'
						    	DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial2Dpasl';
							case 'WIP SOURCE - Axial 2D PASL'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'axial2Dpasl';

							case 'tgse_pcasl_PLD2000'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'pcaslPLD2000'

							case 'Cerebral Blood Flow'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'cbf';

							case 'Perfusion_Weighted'
								DICOM2BIDS(i).perf.asl.BIDS.acquisition = 'perfusionweighted';

						end

						DICOM2BIDS(i).perf.asl.BIDS.session = sid_data.VISCODE{j};




					% ++++++++++++++++++++++++++	
					%            T1
					% ++++++++++++++++++++++++++



					  % 123×1 cell array

					  %   {'           MPRAGE'                     }
					  %   {'3D T1 SAG'                             }
					  %   {'ACCELERATED SAG IR-SPGR'               }
					  %   {'ADNI       MPRAGE'                     }
					  %   {'ADNI       MPRAGE #2'                  }
					  %   {'ADNI       MPRAGE ASO'                 }
					  %   {'ADNI       MPRAGEASOREP'               }
					  %   {'ADNI       MPRAGEREPEAT'               }
					  %   {'ADNI       MPRAGEadni2'                }
					  %   {'ADNI       MPRAGEadni22'               }
					  %   {'ADNI SH    MPRAGE ASO'                 }
					  %   {'ADNI SH    MPRAGE ASOX2'               }
					  %   {'ADNI-R11   MPRAGE'                     }
					  %   {'ADNI-R11   MPRAGE-REPEA'               }
					  %   {'ADNI-R11-ASASO-MPRAGE'                 }
					  %   {'ADNI-R11-ASASO-MPRAGE(2'               }
					  %   {'ADNI_new   MPRAGE'                     }
					  %   {'ADNI_new   MPRAGErepeat'               }
					  %   {'ASO-MPRAGE'                            }
					  %   {'ASO-MPRAGE (2)'                        }
					  %   {'ASO-MPRAGE 2'                          }
					  %   {'Accelerated SAG IR-FSPGR'              }
					  %   {'Accelerated SAG IR-SPGR'               }
					  %   {'Accelerated SAG IR-SPGR REPEAT'        }
					  %   {'Accelerated Sag IR-FSPGR'              }
					  %   {'Accelerated Sag IR-SPGR'               }
					  %   {'Accelerated Sagittal IR-FSPGR'         }
					  %   {'Accelerated Sagittal MPRAGE'           }
					  %   {'Accelerated Sagittal MPRAGE L>>R'      }
					  %   {'Accelerated Sagittal MPRAGE Phase A-P' }
					  %   {'Accelerated Sagittal MPRAGE REPEAT'    }
					  %   {'Accelerated Sagittal MPRAGE repeat'    }
					  %   {'Accelerated Sagittal MPRAGE_MPR_Cor'   }
					  %   {'Accelerated Sagittal MPRAGE_MPR_Tra'   }
					  %   {'Accelerated Sagittal MPRAGE_ND'        }
					  %   {'IR-FSPGR'                              }
					  %   {'IR-FSPGR (replaces MP-Rage)'           }
					  %   {'IR-FSPGR REPEAT'                       }
					  %   {'IR-FSPGR-Repeat'                       }
					  %   {'IR-SPGR'                               }
					  %   {'IR-SPGR w/acceleration'                }
					  %   {'MP RAGE'                               }
					  %   {'MP RAGE REPEAT'                        }
					  %   {'MP RAGE SAGITTAL'                      }
					  %   {'MP RAGE SAGITTAL REPEAT'               }
					  %   {'MP-RAGE'                               }
					  %   {'MP-RAGE  REPEAT'                       }
					  %   {'MP-RAGE #3'                            }
					  %   {'MP-RAGE REPEAT'                        }
					  %   {'MP-RAGE REPEAT #2'                     }
					  %   {'MP-RAGE repeat'                        }
					  %   {'MP-RAGE rpt'                           }
					  %   {'MP-RAGE-'                              }
					  %   {'MP-RAGE-REPEAT'                        }
					  %   {'MP-RAGE-Repeat'                        }
					  %   {'MPRAGE'                                }
					  %   {'MPRAGE  REPEAT'                        }
					  %   {'MPRAGE 2ND'                            }
					  %   {'MPRAGE 3dtf'                           }
					  %   {'MPRAGE 3dtfe'                          }
					  %   {'MPRAGE 3dtferepeat'                    }
					  %   {'MPRAGE ASO'                            }
					  %   {'MPRAGE AUTOSHIM ON'                    }
					  %   {'MPRAGE GRAPPA 2'                       }
					  %   {'MPRAGE GRAPPA 2_ND'                    }
					  %   {'MPRAGE GRAPPA2'                        }
					  %   {'MPRAGE GRAPPA2 rpt'                    }
					  %   {'MPRAGE GRAPPA2_S3_DIS3D'               }
					  %   {'MPRAGE GRAPPA2_S4_DIS3D'               }
					  %   {'MPRAGE NO ANGLE'                       }
					  %   {'MPRAGE REPEAT'                         }
					  %   {'MPRAGE REPEAT ASO'                     }
					  %   {'MPRAGE Repeat'                         }
					  %   {'MPRAGE SAG'                            }
					  %   {'MPRAGE SAGITTAL'                       }
					  %   {'MPRAGE SENS'                           }
					  %   {'MPRAGE SENSE'                          }
					  %   {'MPRAGE SENSE repeat'                   }
					  %   {'MPRAGE SENSE2'                         }
					  %   {'MPRAGE SENSE2 SENSE'                   }
					  %   {'MPRAGE repe'                           }
					  %   {'MPRAGE repeat'                         }
					  %   {'MPRAGE rpt'                            }
					  %   {'MPRAGE-REPEAT'                         }
					  %   {'MPRAGEASO'                             }
					  %   {'MPRAGEREPEAT'                          }
					  %   {'MPRAGEREPEATASO'                       }
					  %   {'MPRAGE_ NO ANGLE='                     }
					  %   {'MPRAGE_ Sag  - NO ANGLE='              }
					  %   {'MPRAGE_ASO'                            }
					  %   {'MPRAGE_ASO_repeat'                     }
					  %   {'MPRAGE_GRAPPA2'                        }
					  %   {'MPRAGE_ND'                             }
					  %   {'MPRAGE_P2_NO ANGLE='                   }
					  %   {'MPRAGE_REPEAT'                         }
					  %   {'MPRAGE_Repeat'                         }
					  %   {'MPRAGE_S2_DIS3D'                       }
					  %   {'MPRAGE_S3_DIS3D'                       }
					  %   {'MPRAGEadni'                            }
					  %   {'REPEAT MP-RAGE'                        }
					  %   {'REPEAT SAG 3D MP RAGE'                 }
					  %   {'REPEAT SAG 3D MP RAGE NO ANGLE'        }
					  %   {'REPEAT SAG 3D MPRAGE'                  }
					  %   {'SAG 3D MPRAGE'                         }
					  %   {'SAG 3D MPRAGE NO ANGLE'                }
					  %   {'SAG IR-FSPGR'                          }
					  %   {'SAG IR-FSPGR-Repeat'                   }
					  %   {'SAG IR-SPGR'                           }
					  %   {'SAG MP-RAGE'                           }
					  %   {'SAG MP-RAGE REPEAT'                    }
					  %   {'SAG MPRAGE GRAPPA2 NO ANGLE'           }
					  %   {'SAG MPRAGE NO ANGLE'                   }
					  %   {'Sag IR-FSPGR'                          }
					  %   {'Sag IR-FSPGR Repeat'                   }
					  %   {'Sag IR-SPGR'                           }
					  %   {'Sag IR-SPGR REPEAT'                    }
					  %   {'Sag IR-SPGR-REPEAT'                    }
					  %   {'Sag MPRAGE'                            }
					  %   {'Sag MPRAGE Repeat'                     }
					  %   {'Sagittal 3D Accelerated 0 angle MPRAGE'}
					  %   {'Sagittal 3D Accelerated MPRAGE'        }
					  %   {'Sagittal 3D Accelerated MPRAGE_REPEAT' }
					  %   {'T1 SAG'                                }

					elseif contains (sid_data.SEQUENCE{j}, possibleT1keywords, 'IgnoreCase', true)

						DICOM2BIDS(i).anat.T1w.DICOM.SeriesDescription = sid_data.SEQUENCE{j};
						DICOM2BIDS(i).anat.T1w.DICOM.PatientID = sid_data.SID{j};
						DICOM2BIDS(i).anat.T1w.DICOM.StudyDate = erase(char(sid_data.SCANDATE(j)),'-');

						T1w_acquisition_label = '';

						if contains (sid_data.SEQUENCE{j}, '3D', 'IgnoreCase', true)

							T1w_acquisition_label = '3D';

						end

						if contains (sid_data.SEQUENCE{j}, {'MPRAGE', 'MP-RAGE', 'MP RAGE'}, 'IgnoreCase', true) && ...
							~ strcmp (sid_data.SEQUENCE{j}, 'IR-FSPGR (replaces MP-Rage)')

							T1w_acquisition_label = [T1w_acquisition_label 'mprage'];

						elseif contains (sid_data.SEQUENCE{j}, 'IR-SPGR', 'IgnoreCase', true)

							T1w_acquisition_label = [T1w_acquisition_label 'irspgr'];

						elseif contains (sid_data.SEQUENCE{j}, 'IR-FSPGR', 'IgnoreCase', true)

							T1w_acquisition_label = [T1w_acquisition_label 'irfspgr'];

						end

						DICOM2BIDS(i).anat.T1w.BIDS.acquisition = T1w_acquisition_label;

						DICOM2BIDS(i).anat.T1w.BIDS.session = sid_data.VISCODE{j};


						% FIND AND DEAL WITH REPEAT
						% ++++++++++++++++++++++++
						if contains (sid_data.SEQUENCE{j}, {'repeat', 'repe', 'rpt','rep', 'repea'}, 'IgnoreCase', true)


				end








				end

			end

				
				

				% DICOM - T1w
				

				% DICOM - FLAIR
				DICOM2BIDS(i).anat.FLAIR.DICOM.SeriesDescription = 'Sagittal 3D FLAIR';
				DICOM2BIDS(i).anat.FLAIR.DICOM.PatientID = ADNI_ASL.SID{i};
				DICOM2BIDS(i).anat.FLAIR.DICOM.StudyDate = erase(char(ADNI_ASL.SCANDATE(i)),'-');

				% BIDS - ASL
				

				% BIDS - T1w
				DICOM2BIDS(i).anat.T1w.BIDS.acquisition = 'acceleratedSagittalMPRAGE';
				DICOM2BIDS(i).anat.T1w.BIDS.session = ADNI_ASL.VISCODE{i};

				% BIDS - FLAIR
				DICOM2BIDS(i).anat.FLAIR.BIDS.acquisition = 'sagittal3DFLAIR';
				DICOM2BIDS(i).anat.FLAIR.BIDS.session = ADNI_ASL.VISCODE{i};


			end

			fprintf ('%s : DICOM2BIDS mapping has been created.\n', mfilename);

			fprintf ('%s : Saving DICOM2BIDS to %s ... ', mfilename, output);

			save (output, 'DICOM2BIDS');

			fprintf ('DONE!\n')


		case 'retrieve'

			if nargin == 2 && endsWith(varargin{1},'.mat')
				predefined_mapping = varargin{1};
			else
				predefined_mapping = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''retrieve'' mode. Will retrieve DICOM2BIDS mapping from %s.\n',mfilename,predefined_mapping);

			fprintf ('%s : Loading %s ... ', mfilename, predefined_mapping);

			DICOM2BIDS = load(predefined_mapping).DICOM2BIDS;

			fprintf ('DONE!\n');
	end

end
	



% REMAINING VALUES IN ADNI_ASL.SEQUENCE TO PROCESS
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
% 435×1 cell array
%
%     {'           Double/TSE'                                          }
%     {'3-pl T2* FGRE S'                                                }
%     {'3Plane Loc SSFSE'                                               }
%     {'3TE Axial T2 Star'                                              }
%     {'3TE Axial T2 Star REPEAT'                                       }
%     {'AAHead_Scout'                                                   }
%     {'AAScout'                                                        }
%     {'ADNI       DOUBLE TSE'                                          }
%     {'ADNI       Double_TSE'                                          }
%     {'ADNI       Double_TSEad'                                        }
%     {'ADNI SH    DOUBLE TSE'                                          }
%     {'ADNI-R11   Double_TSE'                                          }
%     {'ADNI-R11-ASDouble_TSE'                                          }
%     {'ADNI_gre_field_mapping'                                         }
%     {'ADNI_new   Double_TSE'                                          }
%     {'ASSET CALIBRATION'                                              }
%     {'ASSET calibration'                                              }
%     {'AX DTI'                                                         }
%     {'AX Field_mapping'                                               }
%     {'AX PD-T2'                                                       }
%     {'AX PD-T2 NO ANGLE'                                              }
%     {'AX PD-T2 NO ANGLE REPEAT'                                       }
%     {'AX PD-T2, no angle'                                             }
%     {'AX T2 FLAIR'                                                    }
%     {'AX T2 FLAIR NO ANGLE'                                           }
%     {'AX T2 STAR'                                                     }
%     {'AX T2 STAR NO ANGLE'                                            }
%     {'AX T2 TSE with Fat Sat'                                         }
%     {'AXIAL DTI'                                                      }
%     {'AXIAL FLAIR'                                                    }
%     {'AXIAL GRE 5MM'                                                  }
%     {'AXIAL PD T2'                                                    }
%     {'AXIAL PD-T2 TSE'                                                }
%     {'AXIAL PD-T2 TSE (NO ANGLE)'                                     }
%     {'AXIAL PD-T2 TSE REPEAT'                                         }
%     {'AXIAL REFORMAT 2'                                               }
%     {'AXIAL RFORMAT 1'                                                }
%     {'AXIAL RS fMRI (EYES OPEN)'                                      }
%     {'AXIAL T2 STAR'                                                  }
%     {'AXIAL T2-FSE WITH FAT SAT'                                      }
%     {'AXIAL_T2_ STAR'                                                 }
%     {'AXIAL_T2_STAR'                                                  }
%     {'AXIAL_T2_STAR rpt'                                              }
%     {'AXIAL_T2_STAR_repeat'                                           }
%     {'AXIAL_T2_STAR_rpt'                                              }
%     {'AX_T2_FLAIR'                                                    }
%     {'AX_T2_FLAIR_NO ANGLE='                                          }
%     {'AX_T2_STAR'                                                     }
%     {'AX_T2_STAR repeat'                                              }
%     {'AX_T2_STAR_NO ANGLE='                                           }
%     {'Apparent Diffusion Coefficient (mm2/s)'                         }
%     {'Average DC'                                                     }
%     {'Average DC(NEW) 60 SLICES'                                      }
%     {'Average DC:-PJ'                                                 }
%     {'Ax DWI BAYLOR ONLY'                                             }
%     {'Ax T2 FLAIR'                                                    }
%     {'Ax T2 FSE'                                                      }
%     {'Ax T2 FSE with Fat Sat'                                         }
%     {'Axial (STRAIGHT) PD/T2 FSE'                                     }
%     {'Axial 3TE T2 STAR'                                              }
%     {'Axial 3TE T2 STAR  straight no angle'                           }
%     {'Axial 3TE T2 STAR  straight no angle REPEAT'                    }
%     {'Axial 3TE T2 STAR repeat motion'                                }
%     {'Axial 3TE T2 Star'                                              }
%     {'Axial DTI'                                                      }
%     {'Axial DTI (NEW) 60 SLICES'                                      }
%     {'Axial DTI - phase P to A (180 degrees)'                         }
%     {'Axial DTI :-PJ'                                                 }
%     {'Axial DTI Phase Direction P>A'                                  }
%     {'Axial DTI Phase Direction P>A_ADC'                              }
%     {'Axial DTI Phase Direction P>A_FA'                               }
%     {'Axial DTI Phase Direction P>A_TRACEW'                           }
%     {'Axial DTI SEE NOTE)'                                            }
%     {'Axial DTI straight'                                             }
%     {'Axial DTI(HEAD 24)'                                             }
%     {'Axial DTI_ADC'                                                  }
%     {'Axial DTI_FA'                                                   }
%     {'Axial DTI_REPEAT'                                               }
%     {'Axial DTI_TRACEW'                                               }
%     {'Axial DWI'                                                      }
%     {'Axial DWI_ADC'                                                  }
%     {'Axial FLAIR'                                                    }
%     {'Axial Field Mapping'                                            }
%     {'Axial Field Mapping 0 angle'                                    }
%     {'Axial Field Mapping straight'                                   }
%     {'Axial MB DTI'                                                   }
%     {'Axial MB DTI NEW'                                               }
%     {'Axial MB DTI NEW_ADC'                                           }
%     {'Axial MB DTI NEW_TRACEW'                                        }
%     {'Axial MB DTI b0 AP'                                             }
%     {'Axial MB DTI b0 PA'                                             }
%     {'Axial MB DTI low sar'                                           }
%     {'Axial MB DTI phase_noFatSatA'                                   }
%     {'Axial MB DTI_02242020_Moon   straight no angle'                 }
%     {'Axial MB DTI_ADC'                                               }
%     {'Axial MB DTI_ColFA'                                             }
%     {'Axial MB DTI_FA'                                                }
%     {'Axial MB DTI_TENSOR_B0'                                         }
%     {'Axial MB DTI_TRACEW'                                            }
%     {'Axial MB rsfMRI (Eyes Open)'                                    }
%     {'Axial MB rsfMRI (Eyes Open)   straight no angle'                }
%     {'Axial MB rsfMRI (Eyes Open) REPEAT'                             }
%     {'Axial PD-T2 TSE'                                                }
%     {'Axial PD-T2 TSE NO ANGLE'                                       }
%     {'Axial PD-T2 TSE REPEAT'                                         }
%     {'Axial PD/T2 FSE'                                                }
%     {'Axial PD/T2 FSE #2'                                             }
%     {'Axial PD/T2 FSE - 48 slices'                                    }
%     {'Axial PD/T2 FSE REPEAT'                                         }
%     {'Axial PD/T2 FSE RPT'                                            }
%     {'Axial PD/T2 FSE repeat'                                         }
%     {'Axial PD/T2 FSE rpt'                                            }
%     {'Axial RESTING fcMRI (EYES OPEN)'                                }
%     {'Axial STRAIGHT PD/T2 FSE'                                       }
%     {'Axial T2 0 angle Star'                                          }
%     {'Axial T2 FLAIR'                                                 }
%     {'Axial T2 STAR'                                                  }
%     {'Axial T2 STAR phase R-L'                                        }
%     {'Axial T2 Star'                                                  }
%     {'Axial T2 Star (NO ANGLE)'                                       }
%     {'Axial T2 Star REPEAT'                                           }
%     {'Axial T2 Star RPT'                                              }
%     {'Axial T2 Star straight'                                         }
%     {'Axial T2 Star-Repeated with exact copy of FLAIR'                }
%     {'Axial T2 Star_REPEAT'                                           }
%     {'Axial T2 TSE with Fat Sat'                                      }
%     {'Axial T2 TSE with Fat Sat REPEAT'                               }
%     {'Axial T2 TSE with Fat Sat rpt'                                  }
%     {'Axial T2 star'                                                  }
%     {'Axial T2-FLAIR'                                                 }
%     {'Axial T2-FLAIR - REPEAT'                                        }
%     {'Axial T2-FLAIR REPEAT'                                          }
%     {'Axial T2-FLAIR SENSE'                                           }
%     {'Axial T2-FLAIR repeat'                                          }
%     {'Axial T2-FLAIR rpt'                                             }
%     {'Axial T2-FLAIR--'                                               }
%     {'Axial T2-FSE WITH Fat Sat'                                      }
%     {'Axial T2-FSE with FAT SAT'                                      }
%     {'Axial T2-FSE with Fat Sat'                                      }
%     {'Axial T2-Star'                                                  }
%     {'Axial T2-Star REPEAT'                                           }
%     {'Axial T2-Star SENSE'                                            }
%     {'Axial T2-TSE with Fat Sat'                                      }
%     {'Axial T2-TSE with Fat Sat CLEAR'                                }
%     {'Axial T2-TSE with Fat Sat repeat'                               }
%     {'Axial T2star'                                                   }
%     {'Axial fcMRI'                                                    }
%     {'Axial fcMRI (EYES OPEN)'                                        }
%     {'Axial fcMRI (Eyes Open)'                                        }
%     {'Axial fcMRI 0 angle (EYES OPEN)'                                }
%     {'Axial rsfMRI (EYES OPEN)'                                       }
%     {'Axial rsfMRI (Eyes Open)'                                       }
%     {'Axial rsfMRI (Eyes Open) -phase P to A'                         }
%     {'Axial rsfMRI (Eyes Open) 10 min :-PJ'                           }
%     {'Axial rsfMRI (Eyes Open) Phase Direction P>A'                   }
%     {'B1-Calibration'                                                 }
%     {'B1-Calibration 8hrbrn'                                          }
%     {'B1-Calibration BODY'                                            }
%     {'B1-Calibration BODY 5.5MS'                                      }
%     {'B1-Calibration Body'                                            }
%     {'B1-Calibration Body TE 5.5MS'                                   }
%     {'B1-Calibration Body TE 5.5ms'                                   }
%     {'B1-Calibration Body TE =5.5ms'                                  }
%     {'B1-Calibration Body TE=5.5'                                     }
%     {'B1-Calibration Body TE=5.5ms'                                   }
%     {'B1-Calibration Body te 5.5'                                     }
%     {'B1-Calibration Body te=5.5'                                     }
%     {'B1-Calibration HEAD'                                            }
%     {'B1-Calibration Head'                                            }
%     {'B1-Calibration PA'                                              }
%     {'B1-Calibration PA (TE min full)'                                }
%     {'B1-Calibration PA 5.5 TE'                                       }
%     {'B1-Calibration PA TE 5.5'                                       }
%     {'B1-Calibration PA TE =5.5'                                      }
%     {'B1-Calibration PA TE=5.5MS'                                     }
%     {'B1-Calibration PA TE=5.5ms'                                     }
%     {'B1-Calibration PA te 5.5'                                       }
%     {'B1-Calibration PA te 5.5ms'                                     }
%     {'B1-Calibration PA te=5.5ms'                                     }
%     {'B1-calibration Body'                                            }
%     {'B1-calibration Body SAG'                                        }
%     {'B1-calibration Head'                                            }
%     {'B1-calibration Head SAG'                                        }
%     {'B1-calibration PA'                                              }
%     {'CALIBRATION SCAN'                                               }
%     {'COR 3D FRM'                                                     }
%     {'COR HighResHippo'                                               }
%     {'Cal 8HRBRAIN'                                                   }
%     {'Cal Head 24'                                                    }
%     {'Cal Head+Neck 40'                                               }
%     {'Calibration Scan'                                               }
%     {'Cerebral Blood Flow'                                            }
%     {'Coronal T2 HighResHippo'                                        }
%     {'DOUBLE TSE'                                                     }
%     {'DOUBLE_TSE SENSE'                                               }
%     {'DUAL_TSEad'                                                     }
%     {'Double TSE'                                                     }
%     {'Double TSE-repeat'                                              }
%     {'Double-repeat'                                                  }
%     {'Double/TSE'                                                     }
%     {'Double_TSE'                                                     }
%     {'Double_TSE SENSE'                                               }
%     {'Double_TSE_new'                                                 }
%     {'Double_TSE_new SENSE'                                           }
%     {'Enhanced Axial DTI'                                             }
%     {'Extended AXIAL rsfMRI EYES OPEN'                                }
%     {'Extended Resting State fMRI'                                    }
%     {'Extended Resting State fMRI CLEAR'                              }
%     {'FLAIR'                                                          }
%     {'FLAIR AXIAL 5MM'                                                }
%     {'FSE  PD/T2'                                                     }
%     {'FSE PD/T2'                                                      }
%     {'Field Mapping'                                                  }
%     {'Field Mapping    straight no angle'                             }
%     {'Field Mapping CLEAR'                                            }
%     {'Field Mapping Phase Direction P>A'                              }
%     {'Field Mapping REPEAT'                                           }
%     {'Field Mapping R_L'                                              }
%     {'Field Mapping phase R-L'                                        }
%     {'Field Mapping_AP'                                               }
%     {'Field Mapping_ND'                                               }
%     {'Field Mapping_S9_DIS3D'                                         }
%     {'Field_Mapping'                                                  }
%     {'Field_Mapping(EYES OPEN)'                                       }
%     {'Field_mapping'                                                  }
%     {'Fractional Aniso.'                                              }
%     {'Fractional Ansio.'                                              }
%     {'Fractional Ansio.0 SLICES'                                      }
%     {'HighResHippo'                                                   }
%     {'HighResHippo REPEAT'                                            }
%     {'HighResHippo Scan (Oblique - perpendicular to hippocampal tail' }
%     {'HighResHippo Scan (Oblique - perpendicular to hippocampal tail)'}
%     {'HighResHippo Scan REPEAT'                                       }
%     {'HighResHippo repeat'                                            }
%     {'HighResHippo rpt'                                               }
%     {'HighResHippo-fov150tr8020'                                      }
%     {'HighResHippo-fov175tr8020_FA122'                                }
%     {'HighResHippocampus'                                             }
%     {'HighResHippocampus - REPEAT'                                    }
%     {'HighResHippocampus Phase R-L'                                   }
%     {'HighResHippocampus Phase R-L rpt'                               }
%     {'HighResHippocampus REPEAT'                                      }
%     {'HighResHippocampus REPEAT 2'                                    }
%     {'HighRes_Hippo'                                                  }
%     {'Isotropic image'                                                }
%     {'LOC'                                                            }
%     {'Loc'                                                            }
%     {'MoCoSeries'                                                     }
%     {'Perfusion_Weighted'                                             }
%     {'REPEAT Axial T2-FLAIR'                                          }
%     {'Reg - Axial DTI'                                                }
%     {'Resting State fMRI'                                             }
%     {'SAG B1 CALIBRATION BODY'                                        }
%     {'SAG B1 CALIBRATION BODY REPEAT'                                 }
%     {'SAG B1 CALIBRATION HEAD'                                        }
%     {'SAG GRE FIELD MAPPING'                                          }
%     {'SAG T2 TSE with Fat Sat'                                        }
%     {'SCOUT'                                                          }
%     {'SURVEY'                                                         }
%     {'SWI_Images'                                                     }
%     {'Sagittal 3D 0 angle FLAIR'                                      }
%     {'Sagittal 3D FLAIR'                                              }
%     {'Sagittal 3D FLAIR phase A-P'                                    }
%     {'Sagittal 3D FLAIR_MPR_Cor'                                      }
%     {'Sagittal 3D FLAIR_MPR_Tra'                                      }
%     {'SmartBrain'                                                     }
%     {'Survey'                                                         }
%     {'T2 AX'                                                          }
%     {'T2 tse axial hp scout'                                          }
%     {'T2-weighted trace'                                              }
%     {'T2-weighted trace0 SLICES'                                      }
%     {'act_te = 6000 B1-Calibration Body'                              }
%     {'act_te = 6000 B1-Calibration PA'                                }
%     {'ax'                                                             }
%     {'calibration scan'                                               }
%     {'cor'                                                            }
%     {'cor mpr'                                                        }
%     {'dMRI_IXICO_30dir_1b0'                                           }
%     {'gre_field_mapping'                                              }
%     {'gre_field_mapping_NO ANGLE='                                    }
%     {'mIP_Images(SW)'                                                 }
%     {'s Axial 3TE T2 STAR Cumulated'                                  }
%     {'sPWI'                                                           }
%     {'t2_blade_tra'                                                   }
%     {'t2_blade_tra_dark-fl'                                           }



