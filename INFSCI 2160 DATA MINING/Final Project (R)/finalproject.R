# ----------------------------------------------------------------------- #
#	CLASS   :  2157 INFSCI 2160 1310 DATA MINING
#	AUTHOR  :  LAI, LEON <LIL65@PITT.EDU>; FITCH, ADAM <FITCHAD@PITT.EDU>
#	TITLE   :  Final Project
#	DATE    :  2015-08-03
# ----------------------------------------------------------------------- #

data.filename = "BIGDATA_PACT_20150713.csv"
outdir = "finalproject.R.out"

# Load packages for required functions
(function () {
	# lattice::levelplot
	#
	# Nonparametric Missing Value Imputation using Random Forest:
	# missForest::missForest
	#
	# Logistic Regression:
	# stats::glm
	#
	# k-Nearest Neighbors:
	# class::knn
	#
	# Naive Bayes:
	# e1071::naiveBayes
	#
	# Decision Tree:
	# rpart::rpart
	#
	# Support Vector Machine:
	# e1071::svm
	#
	# Adaptive Boosting:
	# ada::ada
	#
	# Random Forest
	# randomForest::randomForest
	#
	# Neural Network
	# nnet::nnet
	#
	# Accuracy, Precision, Recall, F1 score, Area under ROC curve, etc:
	# ROCR::performance
	#
	require (lattice)
	require (missForest)
	require (ada)
	require (class)
	require (e1071)
	require (ROCR)
	require (rpart)
	require (randomForest)
	require (nnet)
}) ()



# ----------------------------------------------------------------------- #
#	LOAD DATA
# ----------------------------------------------------------------------- #

data = (function (filename) {

	# Import data
	# Note that invalid characters in column names are replaced by "." and
	# column names beginning with numeric character are prefixed with "X".
	data = read.csv (
		file = filename
	)

	# Preprocessing tasks:
	# 1. Each variable needs to be casted to the right variable type.
	#    "Unknown", "Refused", etc. values need to be converted to NAs.
	# 2. Unimportant columns and rows need to be removed or combined.
	# 3. This data set has 3 dimensions: person, time, attributes. The
	#    latter two need to be combined or one of them needs to be removed
	#    to make the data 2-D.

	# Preprocess data: Set all blank ("") cells to NA
	data [data == ""] = NA

	# Preprocess data: Look at the domain of each column
	# This was used together with the CODEBOOK file to determine the type
	# of each variable.
	#data.columns.class = list ()
	#data.columns.levels = list ()
	#for (name in colnames (data))
	#{
	#	data.columns.class[[name]] = class(data[[name]])
	#	data.columnw.levels[[name]] = levels(as.factor(data[[name]]))
	#}
	#page (data.columns.class, method = "print")
	#page (data.columns.levels, method = "print")

	# Preprocess data: Date columns
	cc = c (
		"VISIT_DT",
		"CD4_VL_LAB_DT",
		"F21WHEN",
		"G1bDateLastSmoked"
	)
	data [ cc ] = sapply (
		data [ cc ],
		function (data) {as.numeric (as.POSIXct (data, tz = "GMT"))}
	)

	# Preprocess data: Binary variables
	cc = c (
		"HGBU",
		"COHGBU"
	)
	data [ cc ] = data [ cc ] != 0
	cc = c (
		"D11EPIVIR",
		"ZIAG",
		"AGEN",
		"REYATZ",
		"ATRIP",
		"AZT",
		"COMBIV",
		"PREZIS",
		"D4T",
		"DDI",
		"DDC",
		"RESCRIP",
		"SUSTIV",
		"EMTRIV",
		"FUZEO",
		"LEXIVA",
		"CRIZIV",
		"KALETRA",
		"VIRACPT",
		"VIRAMUN",
		"NORVIR",
		"INVIRAS",
		"ZERIT",
		"APTIVUS",
		"VIREAD",
		"TRIZIVIR",
		"TRUVADA",
		"UNK",
		"OTHER"
	)
	data [ cc ] [ data [ cc ] > 2 ] = NA
	data [ cc ] = data [ cc ] != 0
	cc = c (
		"GENDER",
		"A1HIVStatus",
		"A4HOSP",
		"A5PNEU",
		"B1TRAV",
		"B3COUGH",
		"B4PCP",
		"B6CHILD",
		"C1ACTIV",
		"D1SEP",
		"D2RX",
		"D3bEVER",
		"D3cWK",
		"D3eDOSE",
		"D3fYR",
		"D4bEVER",
		"D4cWK",
		"D4d3MO",
		"D4fYR",
		"D5bEVER",
		"D5cWK",
		"D5d3MO",
		"D5fYR",
		"D6bEVER",
		"D6cWEEK",
		"D6d3MO",
		"D6fYR",
		"D7bEVER",
		"D7cWK",
		"D7d3MO",
		"D7fYR",
		"D8CUT",
		"D9MISS",
		"D10HIVMED",
		"ART_CURRENT",
		"D12STER",
		"D13YR",
		"D14IMMUN",
		"D15CHEMO",
		"D163MOINH",
		"D17Albuterol",
		"D17Atrovent",
		"D17Combivent",
		"D17Serevent",
		"D17Spiriva",
		"D17SteroidInhaler",
		"D17Advair",
		"D17Azmacort",
		"D17Flovent",
		"D17Aerobid",
		"D17Pulmicort",
		"D17QVAR",
		"D17Unknown",
		"D18YRINH",
		"D19Albuterol",
		"D19Atrovent",
		"D19Combivent",
		"D19Serevent",
		"D19Spiriva",
		"D19SteroidInhaler",
		"D19Advair",
		"D19Azmacort",
		"D19Flovent",
		"D19Aerobid",
		"D19Pulmicort",
		"D19QVAR",
		"D19Unknown",
		"E1ASTHM",
		"E3STILL",
		"E46MOMED",
		"E5COPD",
		"E7MED",
		"E86MOMED",
		"E9CA",
		"E11SARCOD",
		"E13APNE",
		"E15PHTN",
		"E16TB",
		"E17PCP",
		"E18PNEUM",
		"E19OR",
		"F7DRUGS",
		"F86MO",
		"F9WK",
		"F10MRJ",
		"F116MO",
		"F12WK",
		"F13CC",
		"F146MO",
		"F15WK",
		"F16DM",
		"F18CA",
		"F22HEP",
		"F25TX",
		"G1SMOKE",
		"G8QUIT",
		"G12CIGAR",
		"G12aREG",
		"G13PIPE",
		"G13aREG",
		"G14LIVE",
		"G15HOME",
		"G16ENVIRO",
		"G17STOP",
		"G18PROD",
		"G18aNONE",
		"G18bPATCH",
		"G18cGUM",
		"G18dLOZ",
		"G18eINHAL",
		"G18fSPRAY",
		"G18gZYBAN",
		"G18hCHAN",
		"G18iOTHER",
		"G19METH",
		"G19aNONE",
		"G19bTALK",
		"G19cCOUNS",
		"G19dCLASS",
		"G19eTELE",
		"G19fBOOK",
		"G19gONLINE",
		"G19hALT",
		"G19iTAPE",
		"G19jOTHER",
		"H1COUGH",
		"H1afFREQ",
		"H1bAM",
		"H1cPM",
		"H1dMO",
		"H2PHLGM",
		"H2aFREQ",
		"H2bAM",
		"H2cPM",
		"H2dMO",
		"H3WHEZ",
		"H3aFREQ",
		"H3bTX",
		"H3cYR",
		"H3dCOLD",
		"H3eOTHER",
		"H3fWK",
		"H3gMOST",
		"H4WALK",
		"H5SOB",
		"H5aSLOW",
		"H5bSTOP",
		"H5cMIN",
		"H5dADLS",
		"H6FEV",
		"H8CONG",
		"H10THROT",
		"I1JOBS",
		"I2EXPOS",
		"I2aGAS",
		"I2bFIRE",
		"I2cOIL",
		"I2dDUST",
		"I2eSAND",
		"I2fFUEL",
		"I2gENGIN",
		"I2hGRAIN",
		"I2iANIMAL",
		"I2jCOTON",
		"I2kWOOD",
		"I2lCAD",
		"I2mMETAL",
		"I2nWELD",
		"I2oFIBGLA",
		"I2pEXPL",
		"I2qOTHER",
		"J1aCOPD",
		"J1bASTHM",
		"J1cCA",
		"J1dOTHER",
		"PFT",
		"ATS",
		"CT",
		"ECHO",
		"Diastolic.Dysfunction",
		"LeftVentricularHypertrophy",
		"LeftAtriumEnlargement",
		"AorticRootDilatation",
		"TricuspidValve",
		"PulmonicValve",
		"AorticValve",
		"MitralValve",
		"TWHIPPLEI"
	)
	data [ cc ] [ data [ cc ] > 1 ] = NA
	data [ cc ] = data [ cc ] != 0

	# Preprocess data: Categorical (qualitative) variables
	data [ "RACE"     ] [ data [ "RACE"     ] > 6 ] = NA
	data [ "A2HIV"    ] [ data [ "A2HIV"    ] > 3 ] = NA
	data [ "F17WHERE" ] [ data [ "F17WHERE" ] > 3 ] = NA
	data [ "F19WHERE" ] [ data [ "F19WHERE" ] > 3 ] = NA
	data [ "F24WHERE" ] [ data [ "F24WHERE" ] > 3 ] = NA
	cc = c (
		"VISIT",
		"RACE",
		"A2HIV",
		"E2AGE",
		"E6AGE",
		"E10AGE",
		"E12AGE",
		"E14AGE",
		"F17WHERE",
		"F19WHERE",
		"F24WHERE",
		"G4NOW",
		"G11aREG",
		"PRE_ACCEPTABLE",
		"POST_ACCEPTABLE",
		"DLCO_ACCEPTABLE",
		"DD_Severity",
		"LVH_Severity",
		"LAE_Severity",
		"ARD_Severity",
		"TV_Abnormality",
		"TV_Severity",
		"PV_Abnormality",
		"PV_Severity",
		"AV_Abnormality",
		"AV_Severity",
		"MV_Abnormality",
		"MV_Severity"
	)
	data [ cc ] = lapply (data [ cc ], as.factor)

	# Preprocess data: Continuous (quantitative) variables
	cc = c (
		"AgeInfected",
		"AGE",
		"WT",
		"BMI",
		"TEMP",
		"BPSYS",
		"BPDIA",
		"PULSE",
		"RESP",
		"CD4",
		"VL",
		"B5HRS",
		"B7HRS",
		"C2HRSWK",
		"D3d3MO",
		"D4eDOSE",
		"D5eDOSE",
		"D6eDOSE",
		"D7eDOSE",
		"TIMES",
		"E2AgeYears",
		"E6AgeYears",
		"E10AgeYears",
		"E12AgeYears",
		"E14AgeYears",
		"G1aYRSSMOKED",
		"G2AGE",
		"G3CPD",
		"G5AVG",
		"G630DAY",
		"G7CIGDAY",
		"G9AGE",
		"G10LQUIT",
		"G11LGQUIT",
		"G11bYRS",
		"PACK_YEARS",
		"H11LONG",
		"I2aGASYears",
		"I2bFIREYears",
		"I2cOILYears",
		"I2dDUSTYears",
		"I2eSANDYears",
		"I2fFUELYears",
		"I2gENGINYears",
		"I2hGRAINYears",
		"I2iANIMALYears",
		"I2jCOTONYears",
		"I2kWOODYears",
		"I2lCADYears",
		"I2mMETALYears",
		"I2nWELDYears",
		"I2oFIBGLAYears",
		"I2pEXPLYears",
		"I2qOtherYears",
		"PRE_FVC",
		"PRE_FVCPP",
		"PRE_FEV1",
		"PRE_FEV1PP",
		"PRE_FEF25",
		"PRE_FEF25PP",
		"PRE_FEV1FVC",
		"POST_FVC",
		"POST_FVCPP",
		"POST_FEV1",
		"POST_FEV1PP",
		"POST_FEF25",
		"POST_FEF25PP",
		"POST_FEV1FVC",
		"DLCO",
		"DLCOPP_FINAL",
		"HGB",
		"COHGB",
		"frac_910",
		"frac_950",
		"WAperc_mean_all",
		"WAperc_std_all",
		"WAperc_mean_lrg",
		"WAperc_std_lrg",
		"WAperc_mean_mdm",
		"WAperc_std_mdm",
		"WAperc_mean_sml",
		"WAperc_std_sml",
		"EjectionFractionLowerLimit",
		"EjectionFractionUpperLimit",
		"DiastolicDiameter",
		"SystolicDiameter",
		"SeptalThickness",
		"PostWallThickness",
		"AorticRoot",
		"LeftAtrium",
		"PulmonaryArterySystolicPressure",
		"TRV",
		"ADIPONECTIN",
		"ARG",
		"ADMA",
		"SDMA",
		"ANA_1TO40_CUTOFF",
		"ANA_PATTERN",
		"BETA_GLUCAN",
		"BNP",
		"CREATININE",
		"HSCRP",
		"IGE",
		"IGG_TITER",
		"IGM_TITER",
		"IL6",
		"IL6_SD",
		"IL8",
		"IL8_SD",
		"MTLSU_IS",
		"MTLSU_OW",
		"MMP1_IS",
		"MMP2_IS",
		"MMP3_IS",
		"MMP7_IS",
		"MMP8_IS",
		"MMP9_IS",
		"MMP12_IS",
		"MMP13_IS",
		"MMP1_PL",
		"MMP2_PL",
		"MMP3_PL",
		"MMP7_PL",
		"MMP8_PL",
		"MMP9_PL",
		"MMP12_PL",
		"MMP13_PL"
	)
	data [ cc ] = sapply (data [ cc ], as.numeric)

	# Preprocess data: Text variables
	data [ "F20KIND" ] [ data [ "F20KIND" ] %in% c (8, 9) ] = NA
	data [ "F23TYPE" ] [ data [ "F23TYPE" ] %in% c (   9) ] = NA
	cc = c (
		"A2HIV_OtherSource",
		"B2WHERE",
		"TYPE",
		"REASON",
		"D7aSpecify",
		"DOSE",
		"SPECIFY",
		"DATES",
		"D17Other",
		"D19Other",
		"SPECIFY1",
		"MOYR",
		"PLACE",
		"PLACE1",
		"F20KIND",
		"F23TYPE",
		"F24PLACE",
		"F26MED",
		"G18SPECIFY",
		"G19jSpecify",
		"H1eYRS",
		"H2eYRS",
		"H5eYRS",
		"H7LONG",
		"H9LONG",
		"X12qSPECIFY",
		"J1DSPECIF",
		"PFT_NOTES"
	)
	data [ cc ] = sapply (data [ cc ], as.character)

	data
}) (data.filename)

data.backup.0_loaded = data



# ----------------------------------------------------------------------- #
#	REDUCE COLUMNS AND ROWS, PART 1
# ----------------------------------------------------------------------- #

data = (function (data) {

	# Row reduction
	data = data [
		data $ A1HIVStatus &
		! is.na (data $ POST_FEV1FVC) &
		data $ Id %in% names (which (table (data $ Id) > 1)),
	]

	# Get columns that are 50% or more blank for at least one VISIT
	# Besides dependence, the missingness of a column can also indicate
	# its unimportance and thus justify its removal.
	#page (names (which (sapply (
	#	X = data,
	#	FUN = function (x) {
	#		any (sapply (
	#			X = levels (data $ VISIT),
	#			FUN = function (y) {
	#				mean (is.na (x [ data $ VISIT == y ] )) >= 0.5
	#			}
	#		))
	#	}
	#))))

	# Replace VL with log(VL+1)
	data $ VL = log1p (data $ VL + 1)
	names (data) [ names (data) == "VL" ] = "VL_LOG"

	#all(!is.na(data$B5HRS[data$B3COUGH]))
	# [1] FALSE

	#all(!is.na(data$B7HRS[data$B6CHILD]))
	# [1] TRUE
	data $ B7HRS [ ! data $ B6CHILD ] = 0

	#all(!is.na(data$C2HRSWK[data$C1ACTIV]))
	# [1] TRUE
	data $ C2HRSWK [ ! data $ C1ACTIV ] = 0

	data $ E17_18PNEUM = data $ E17PCP | data $ E18PNEUM

	# Remove columns
	data = data [ ! names (data) %in% c (

		# Accounted for by VISIT
		"VISIT_DT",

		# Unimportant
		"CD4_VL_LAB_DT",

		# Rows where A1HIVStatus is FALSE have been removed
		"A1HIVStatus",

		# Accounted for by A1HIVStatus
		grep ("^A2", names (data), value = TRUE),

		# Too sparse
		"A5PNEU",

		# Accounted for by B1TRAV
		"B2WHERE",

		# Accounted for by B3COUGH
		"B4PCP",
		"B5HRS",

		# Accounted for by B7HRS
		"B6CHILD",

		# Accounted for by C2HRSWK
		"C1ACTIV",
		"TYPE",

		# Accounted for by D1SEP
		"REASON",

		# Accounted for by D2RX
		# It is the OR of the D?bEVER columns
		"D3bEVER",
		"D3cWK",
		"D3d3MO",
		"D3eDOSE",
		"D3fYR",
		"D4bEVER",
		"D4cWK",
		"D4d3MO",
		"D4eDOSE",
		"D4fYR",
		"D5bEVER",
		"D5cWK",
		"D5d3MO",
		"D5eDOSE",
		"D5fYR",
		"D6bEVER",
		"D6cWEEK",
		"D6d3MO",
		"D6eDOSE",
		"D6fYR",
		"D7aSpecify",
		"D7bEVER",
		"D7cWK",
		"D7d3MO",
		"D7eDOSE",
		"D7fYR",
		"D8CUT",
		"DOSE",
		"D9MISS",
		"TIMES",

		# Accounted for by the 29 columns of D11
		# It is the OR of them
		"D10HIVMED",
		"ART_CURRENT",
		"SPECIFY",

		# Accounted for by D13YR
		"D12STER",

		# Accounted for by D15CHEMO
		"DATES",

		# Accounted for by D163MOINH
		grep ("^D17", names (data), value = TRUE),

		# Accounted for by D18YRINH
		grep ("^D19", names (data), value = TRUE), "D163MOINH",

		# Accounted for by E1ASTHM
		"E2AGE",
		"E2AgeYears",
		"E3STILL",
		"E46MOMED",

		# Accounted for by E5COPD
		"E6AGE",
		"E6AgeYears",
		"E7MED",
		"E86MOMED",

		# Accounted for by E9CA
		"E10AGE",
		"E10AgeYears",

		# Accounted for by E11SARCOD
		"E12AGE",
		"E12AgeYears",

		# Accounted for by E13APNE
		"E14AGE",
		"E14AgeYears",

		# Accounted for by E15PHTN
		"SPECIFY1",
		"MOYR",

		# Merged into E17_18PNEUM
		"E17PCP",
		"E18PNEUM",

		# Accounted for by F7DRUGS
		"F86MO",
		"F9WK",

		# Accounted for by F10MRJ
		"F116MO",
		"F12WK",

		# Accounted for by F13CC
		"F146MO",
		"F15WK",

		# Accounted for by F16DM
		"F17WHERE",
		"PLACE",

		# Accounted for by F18CA
		"F19WHERE",
		"PLACE1",
		"F20KIND",
		"F21WHEN",

		# Accounted for by F22HEP
		"F23TYPE",
		"F24WHERE",
		"F24PLACE",
		"F25TX",
		"F26MED",

		# Accounted for by PACK_YEARS
		grep ("^G\\d", names (data), value = TRUE),

		# Accounted for by H1COUGH
		"H1afFREQ",
		"H1bAM",
		"H1cPM",
		"H1dMO",
		"H1eYRS",

		# Accounted for by H2PHLGM
		"H2aFREQ",
		"H2bAM",
		"H2cPM",
		"H2dMO",
		"H2eYRS",

		# Accounted for by H3WHEZ
		"H3aFREQ",
		"H3bTX",
		"H3cYR",
		"H3dCOLD",
		"H3eOTHER",
		"H3fWK",
		"H3gMOST",

		# Accounted for by H5SOB
		"H5aSLOW",
		"H5bSTOP",
		"H5cMIN",
		"H5dADLS",
		"H5eYRS",

		# Accounted for by H6FEV
		"H7LONG",

		# Accounted for by H8CONG
		"H9LONG",

		# Accounted for by H10THROT
		"H11LONG",

		# Accounted for by I1JOBS
		grep("^I2",names(data),value=TRUE),"X12qSPECIFY",

		# Accounted for by J1dOTHER
		"J1DSPECIF",

		# Accounted for by PRE_, POST_, DLCO, HGB, and COHGB columns
		# If FALSE then they are NA
		"PFT",

		# Accounted for by PFT
		"PFT_NOTES",

		#
		"ATS",

		# Accounted for by other PRE_ columns
		# If 0 or 2 then they are NA
		"PRE_ACCEPTABLE",

		# Accounted for by PRE_FEV1FVC
		"PRE_FVC",
		"PRE_FVCPP",
		"PRE_FEV1",
		"PRE_FEV1PP",
		"PRE_FEF25",
		"PRE_FEF25PP",

		# Less important than its POST_ counterpart
		"PRE_FEV1FVC",

		# Accounted for by other POST_ columns (if 0 or 2 then they are NA)
		"POST_ACCEPTABLE",

		# Accounted for by POST_FEV1PP
		"POST_FVC",
		"POST_FVCPP",
		"POST_FEV1",
		"POST_FEV1FVC",
		"POST_FEF25",
		"POST_FEF25PP",

		# Accounted for by other DLCO columns
		# If 0 or 2 then they are be NA
		"DLCO_ACCEPTABLE",

		# Accounted for by DLCOPP_FINAL
		"DLCO",
		"HGB",
		"COHGB",

		# Accounted for by HGB
		# NA means HGBU is TRUE
		"HGBU",

		# Accounted for by COHGB
		# NA means COHGBU is TRUE
		"COHGBU",

		# Accounted for by frac_ and WAperc columns
		# If FALSE then they are NA
		"CT",

		# Accounted for by the 30 columns following it
		# If FALSE they they are NA
		"ECHO",

		# Accounted for by DD_Severity
		"Diastolic.Dysfunction",

		# Accounted for by LVH_Severity
		"LeftVentricularHypertrophy",

		# Accounted for by LAE_Severity
		"LeftAtrium",
		"LeftAtriumEnlargement",

		# Not sure why but Adam took this out
		"PulmonaryArterySystolicPressure",

		# Accounted for by ARD_Severity
		"AorticRootDilatation",

		# Accounted for by TV_Severity
		"TricuspidValve",
		"TV_Abnormality",

		# Accounted for by PV_Severity
		"PulmonicValve",
		"PV_Abnormality",

		# Accounted for by AV_Severity
		"AorticValve",
		"AV_Abnormality",

		# Not sure why but Adam took this out
		"AV_Severity",

		# Accounted for by MV_Severity
		"MitralValve",
		"MV_Abnormality"
	)]

	data
}) (data)

data.backup.1_reduced_part_1 = data # Caution: used later on



# ----------------------------------------------------------------------- #
#	MERGE TIME AND ATTRIBUTE DIMENSIONS
# ----------------------------------------------------------------------- #

data = (function (data) {

	# Define primary key a.k.a. row ID
	# The primary key at this point is (Id, VISIT), but later we are going
	# to merge VISIT into the attributes dimension, i.e. drop it and make
	# a set of the other columns for each of its possible values.
	data.pk.keep = "Id"
	data.pk.rid  = "VISIT"

	# Find all columns that Id alone can determine
	# Later when we reshape data from long to wide we will exclude these
	# ones from widening.
	#data.columns.apparently_determinable_by_pk = c ()
	#data.columns.apparently_determinable_by_pk.non_blank = c ()
	#for (name in setdiff (names (data), c (data.pk.keep, data.pk.rid)))
	#{
	#	if (
	#		identical (
	#			unique(data[,c(data.pk.keep,name)])[[data.pk.keep]],
	#			unique(data[[data.pk.keep]])
	#		)
	#	)
	#	{
	#		data.columns.apparently_determinable_by_pk = c (
	#			data.columns.apparently_determinable_by_pk,
	#			name
	#		)
	#		if (
	#			! all (is.na (unique (
	#				unique(data[,c(data.pk.keep,name)])[[name]]
	#			)))
	#		)
	#		{
	#			data.columns.apparently_determinable_by_pk.non_blank=c(
	#				data.columns.apparently_determinable_by_pk.non_blank,
	#				name
	#			)
	#		}
	#	}
	#}
	#page (data.columns.apparently_determinable_by_pk)
	# c("AgeInfected", "GENDER", "RACE")
	#page (data.columns.apparently_determinable_by_pk.non_blank)
	# c("AgeInfected", "GENDER", "RACE")
	data.columns.determinable_by_pk = c("AgeInfected", "GENDER", "RACE")

	# Preprocess data: "long" to "wide"
	# One row per Id, with data associated with each VISIT present as
	# differentcolumns, rather than one row per each VISIT per Id, where
	# data associatedwith each VISIT present is a different row. This
	# merges VISIT into the attributes dimension.
	data = reshape (
		data = data,
		timevar = data.pk.rid,
		idvar = c (data.pk.keep, data.columns.determinable_by_pk),
		direction = "wide"
	)

	# Preprocess data: primary key -> row names; remove primary key column
	rownames (data) = data [[ data.pk.keep ]]
	data = data [ , names (data) != data.pk.keep ]

	data
}) (data)

data.backup.2_wide = data



# ----------------------------------------------------------------------- #
#	REDUCE COLUMNS AND ROWS, PART 2
# ----------------------------------------------------------------------- #

data = (function (data) {

	# Inspect resulting trios of columns
	# This was used together with PART 1 to collapse columns at this stage
	colMeans(is.na(data))
	sapply (
		names (data.backup.1_reduced_part_1),
		function (x) {
			column_trio = data[grep(paste0(x,"\\."),names (data))]
			column_trio.naness = colMeans (is.na (column_trio))
			column_trio.naness.overall = mean(column_trio.naness)
			#c(column_trio.naness,overall=column_trio.naness.overall)
			column_trio.naness.overall
		}
	)
	# - Retain only the last AGE

	# Collapse some column trios
	cc = c (
		"D2RX",
		"E1ASTHM",
		"E5COPD",
		"E9CA",
		"E11SARCOD",
		"E13APNE",
		"E15PHTN",
		"E16TB",
		"E17_18PNEUM",
		"E19OR",
		"F7DRUGS",
		"F10MRJ",
		"F13CC",
		"F16DM",
		"F18CA",
		"F22HEP",
		"H1COUGH",
		"H2PHLGM",
		"H3WHEZ",
		"H4WALK",
		"H5SOB",
		"H6FEV",
		"H8CONG",
		"H10THROT",
		"I1JOBS",
		"J1aCOPD",
		"J1bASTHM",
		"J1cCA",
		"J1dOTHER",
		"DD_Severity",
		"EjectionFractionLowerLimit",
		"EjectionFractionUpperLimit",
		"LVH_Severity",
		"DiastolicDiameter",
		"SystolicDiameter",
		"SeptalThickness",
		"PostWallThickness",
		"AorticRoot",
		"LAE_Severity",
		"ARD_Severity",
		"TV_Severity",
		"PV_Severity",
		"MV_Severity",
		"TRV",
		"ADIPONECTIN",
		"ARG",
		"ADMA",
		"SDMA",
		"ANA_1TO40_CUTOFF",
		"ANA_PATTERN",
		"BETA_GLUCAN",
		"BNP",
		"CREATININE",
		"HSCRP",
		"IGE",
		"IGG_TITER",
		"IGM_TITER",
		"IL6",
		"IL6_SD",
		"IL8",
		"IL8_SD",
		"MTLSU_IS",
		"MTLSU_OW",
		"MMP1_IS",
		"MMP2_IS",
		"MMP3_IS",
		"MMP7_IS",
		"MMP8_IS",
		"MMP9_IS",
		"MMP12_IS",
		"MMP13_IS",
		"MMP1_PL",
		"MMP2_PL",
		"MMP3_PL",
		"MMP7_PL",
		"MMP8_PL",
		"MMP9_PL",
		"MMP12_PL",
		"MMP13_PL",
		"TWHIPPLEI"
	)
	for (name in cc)
	{
		if (is.numeric (data [[ paste0 (name, ".BASE") ]])) {
			data [[ name ]] = apply (
				data [ grep (
					paste0 ("^", name, "\\."),
					names (data)
				) ],
				1,
				mean,
				na.rm=TRUE
			)
			data = data [ grep (
				paste0 ("^", name, "\\."),
				names (data),
				invert = TRUE
			)]
		} else if (is.logical (data [[ paste0 (name, ".BASE") ]])) {
			data [[ name ]] = apply (
				data [ grep (
					paste0 ("^", name, "\\."),
					names (data)
				) ],
				1,
				any,
				na.rm=TRUE
			)
			data = data [ grep (
				paste0 ("^", name, "\\."),
				names (data),
				invert = TRUE
			)]
		} else {
			#message ("Combining columns: Cannot handle ", name)
			data [[ name ]] = apply (
				data [ grep (
					paste0 ("^", name, "\\."),
					names (data)
				) ],
				1,
				function (x) {
					round(mean(as.numeric(x),na.rm=TRUE))
				}
			)
			data = data [ grep (
				paste0 ("^", name, "\\."),
				names (data),
				invert = TRUE
			)]
		}
	}
	data
}) (data)

data.backup.3_reduced_part_2 = data # Caution: used later on



# ----------------------------------------------------------------------- #
#	IMPUTE MISSING DATA
# ----------------------------------------------------------------------- #

leon.mode = function (x, na.rm = FALSE) {
	if (na.rm) x = x [! is.na (x)]
	ux = unique (x)
	tab = tabulate (match (x, ux))
	x.mode = ux [ tab == max (tab) ]
	if (length (x.mode) > 1) x.mode = sample (x.mode, 1)
	x.mode
}

leon.impute = function (data,impute_method) {

	set.seed (12345)

	switch (

		impute_method,

		# Option 1: Mean or mode
		as.data.frame (lapply(data, function (x) {
			if (is.numeric(x)) x[is.na(x)] = mean(x,na.rm=TRUE)
			else x[is.na(x)] = leon.mode(x,na.rm=TRUE)
			x
		}), row.names = rownames (data)),

		# Option 2: Median or mode
		as.data.frame (lapply(data, function (x) {
			if (is.numeric(x)) x[is.na(x)] = median(x,na.rm=TRUE)
			else x[is.na(x)] = leon.mode(x,na.rm=TRUE)
			x
		}), row.names = rownames (data)),

		# Option 3: missForest
		(function (data) {
			data = missForest (data) $ ximp

			# missForest converted logical columns to numeric
			# this corrects it
			for (name in names (data)) {
				if (is.logical (data.backup.3_reduced_part_2[[name]])){
					data [[ name ]] =  data [[ name ]] >= 0.5
				}
			}

			data
		}) (data)
	)
}

data.backup.4_imputed_mean_mode = leon.impute (data, 1)
data.backup.4_imputed_medi_mode = leon.impute (data, 2)
data.backup.4_imputed_missForest = leon.impute (data, 3)
data = data.backup.4_imputed_missForest



# ----------------------------------------------------------------------- #
#	CREATE THREE DATA SETS
# ----------------------------------------------------------------------- #

# The all-VISIT data set
data.all_VISIT = (function (data) {

	data.all_VISIT = data
	data.all_VISIT $ AGE = data.all_VISIT $ AGE.36MO
	data.all_VISIT = data.all_VISIT [
		grep ("AGE\\.", names (data.all_VISIT), invert = TRUE)
	]
	data.all_VISIT
}) (data)

# The two-VISIT data set
data.two_VISIT = (function (data) {

	data.columns.constant_over_VISIT = grep (
		"\\.",
		names (data),
		value = TRUE,
		invert = TRUE
	)

	data.two_VISIT.part_1 = data [ c (
		data.columns.constant_over_VISIT,
		grep ("\\.BASE$", names (data), value = TRUE),
		grep ("\\.18MO$", names (data), value = TRUE),
		grep ("\\.BASE_18MO$", names (data), value = TRUE)
	) ]
	rownames (data.two_VISIT.part_1) = paste0 (
		rownames (data.two_VISIT.part_1),
		".BASE_18MO"
	)

	data.two_VISIT.part_2 = data [ c (
		data.columns.constant_over_VISIT,
		grep ("\\.18MO$", names (data), value = TRUE),
		grep ("\\.36MO$", names (data), value = TRUE),
		grep ("\\.18MO_36MO$", names (data), value = TRUE)
	) ]
	names (data.two_VISIT.part_2) = sub (
		"\\.18MO$",
		".BASE",
		names (data.two_VISIT.part_2)
	)
	names (data.two_VISIT.part_2) = sub (
		"\\.36MO$",
		".18MO",
		names (data.two_VISIT.part_2)
	)
	names (data.two_VISIT.part_2) = sub (
		"\\.18MO_36MO$",
		".BASE_18MO",
		names (data.two_VISIT.part_2)
	)
	rownames (data.two_VISIT.part_2) = paste0 (
		rownames (data.two_VISIT.part_2),
		".18MO_36MO"
	)

	data.two_VISIT = rbind (
		data.two_VISIT.part_1,
		data.two_VISIT.part_2
	)

	data.two_VISIT $ AGE = data.two_VISIT $ AGE.18MO
	data.two_VISIT = data.two_VISIT [
		grep ("AGE\\.", names (data.two_VISIT), invert = TRUE)
	]

	data.two_VISIT
}) (data)

# The one-VISIT data set
data.one_VISIT = (function (data) {

	data.columns.constant_over_VISIT = grep (
		"\\.",
		names (data),
		value = TRUE,
		invert = TRUE
	)

	data.one_VISIT.part_1 = data [ c (
		data.columns.constant_over_VISIT,
		grep ("\\.BASE$", names (data), value = TRUE)
	) ]
	names (data.one_VISIT.part_1) = sub (
		"\\.BASE$",
		"",
		names (data.one_VISIT.part_1)
	)
	rownames (data.one_VISIT.part_1) = paste0 (
		rownames (data.one_VISIT.part_1),
		".BASE"
	)

	data.one_VISIT.part_2 = data [ c (
		data.columns.constant_over_VISIT,
		grep ("\\.18MO$", names (data), value = TRUE)
	) ]
	names (data.one_VISIT.part_2) = sub (
		"\\.18MO$",
		"",
		names (data.one_VISIT.part_2)
	)
	rownames (data.one_VISIT.part_2) = paste0 (
		rownames (data.one_VISIT.part_2),
		".18MO"
	)

	data.one_VISIT.part_3 = data [ c (
		data.columns.constant_over_VISIT,
		grep ("\\.36MO$", names (data), value = TRUE)
	) ]
	names (data.one_VISIT.part_3) = sub (
		"\\.36MO$",
		"",
		names (data.one_VISIT.part_3)
	)
	rownames (data.one_VISIT.part_3) = paste0 (
		rownames (data.one_VISIT.part_3),
		".36MO"
	)

	data.one_VISIT = rbind (
		data.one_VISIT.part_1,
		data.one_VISIT.part_2,
		data.one_VISIT.part_3
	)

	data.one_VISIT = data.one_VISIT [
		! is.na (data.one_VISIT $ POST_FEV1FVC),
	]

	data.one_VISIT
}) (data)



# ----------------------------------------------------------------------- #
#	SUMMARIZE DATA
# ----------------------------------------------------------------------- #

# This function generates a summary (like base::summary but more
# informative and write.csv friendly) and optionally exports a histogram
# for each column of data. Histograms of logical columns do not contain
# two columns if one of the values has 0% frequency.
leon.summarize = function (data, distplot.filename.prefix = "") {

	I      = length (names (data))
	name   = character (I)
	min    = numeric (I)
	Q1     = numeric (I)
	median = numeric (I)
	Q3     = numeric (I)
	max    = numeric (I)
	mean   = numeric (I)
	sd     = numeric (I)
	freq   = numeric (I)
	NAs.count = numeric (I)
	NAs.rate  = numeric (I)

	for (i in 1:I)
	{
		x = data [[ i ]]

		name [i] = names (data) [i]

		if (is.logical (x) | is.factor (x))
		{
			prop.table (table (x, useNA = "no")) -> t
			min    [i] = NA
			Q1     [i] = NA
			median [i] = NA
			Q3     [i] = NA
			max    [i] = NA
			mean   [i] = NA
			sd     [i] = NA
			freq   [i] = paste0 (
				names(t), ": ", t*100, "%",
				collapse = "\n"
			)
			if (distplot.filename.prefix != "")
			{
				png (paste0 (distplot.filename.prefix, ".", name [i], ".png"), bg = "transparent")
				barplot (t, main = paste("Distribution of", name [i]), ylim = c (0, 1))
				dev.off ()
			}
		}
		else if (is.numeric (x))
		{
			quantile (x, na.rm = TRUE) -> quartiles
			min    [i] = quartiles [[  "0%"]]
			Q1     [i] = quartiles [[ "25%"]]
			median [i] = quartiles [[ "50%"]]
			Q3     [i] = quartiles [[ "75%"]]
			max    [i] = quartiles [["100%"]]
			mean   [i] = mean (x, na.rm = TRUE)
			sd     [i] = sd   (x, na.rm = TRUE)
			freq   [i] = NA
			if (distplot.filename.prefix != "")
			{
				png (paste0 (distplot.filename.prefix, ".", name [i], ".png"), bg = "transparent")
				hist (x, main = paste("Distribution of", name [i]))
				dev.off ()
			}
		}
		else
		{
			message ("No summary for ", name [i])
		}

		sum (is.na (x))
		NAs.count [i] = sum (is.na (x))
		NAs.rate  [i] = sum (is.na (x)) / length (x)
	}

	return (
		data.frame (
			min,Q1,median,Q3,max,mean,sd,freq,NAs.count,NAs.rate,
			row.names = name
		)
	)
}

#write.csv (
#	leon.summarize (
#		data.all_VISIT,
#		paste0 (outdir, "/data.all_VISIT.summary")
#	),
#	paste0 (outdir, "/data.all_VISIT.summary.csv"),
#	na = ""
#)



# ----------------------------------------------------------------------- #
#	GET CORRELATION MATRIX
# ----------------------------------------------------------------------- #

# All variables converted to numeric
data.all_VISIT.n = as.data.frame (
	lapply (
		data.all_VISIT,
		as.numeric
	),
	row.names = rownames (data.all_VISIT)
)

# Function to get matrix of time series
leon.to_time_series.for.finalproject.data.all_VISIT = function (data) {

	varseq = sub (
		"\\.BASE$",
		"",
		grep (
			"\\.BASE$",
			names (data.all_VISIT),
			value = TRUE
		)
	)
	idseq = rownames (data)
	timeseq = c ("BASE", "18MO", "36MO")

	l = list()
	i = 1
	for (var in varseq)
	{
		t.class = class (data [[ paste0(var,".",timeseq[1]) ]])
		if (t.class == "factor") {
			t.levels = levels (data [[ paste0(var,".",timeseq[1]) ]])
		}

		for (id in idseq)
		{
			t = c ()

			for (time in timeseq)
			{
				t.next = data [ id, paste0(var,".",time) ]
				if (length(t.next)==0) {
					t.next = NA
				}
				t = c (t, t.next)
			}

			class (t) = t.class
			if (t.class == "factor") levels (t) = t.levels
			l[[i]] = t
			i = i + 1
		}
	}
	dim      (l) = c (length (idseq), length (varseq))
	rownames (l) = idseq
	colnames (l) = varseq
	l
}

# Function to get average cross correlation of time series
leon.cross_correlate = function (
	data.3D,
	vars.1 = colnames (data.3D),
	vars.2 = colnames (data.3D),
	mean.na.rm = TRUE,
	ccf.na.action = na.pass
) {
	sapply (
		X = vars.1,
		FUN = function (var.1) {
			sapply (
				X = vars.2,
				FUN = function (var.2) {
					mean(
						sapply (
							X = rownames(data.3D),
							FUN = function (Id) {
								ccc = ccf (
									data.3D [ Id, var.1 ] [[1]],
									data.3D [ Id, var.2 ] [[1]],
									plot = FALSE,
									na.action = ccf.na.action
								)
								ccc$acf[ccc$lag==0]
							}
						),
						na.rm = mean.na.rm
					)
				}
			)
		}
	)
}

# Get average cross correlation of time series
#data.all_VISIT.3D.ccf = leon.cross_correlate (
#	leon.to_time_series.for.finalproject.data.all_VISIT (
#		data.all_VISIT.n
#	),
#	"POST_FEV1PP"
#)

# Get correlation matrix
data.all_VISIT.cor = cor (data.all_VISIT.n)
write.csv(data.all_VISIT.cor,paste0(outdir,"/data.all_VISIT.cor.csv"),na="")
png(paste0(outdir,"/data.all_VISIT.cor.png"),width=1920,height=1920)
levelplot(data.all_VISIT.cor)
dev.off()



# ----------------------------------------------------------------------- #
#	CLASSIFICATION/REGRESSION
# ----------------------------------------------------------------------- #

# Classify
#
# y_name         : Name of the response variable
# test           : Test set
# train          : Training set
# algorithm_name : Name of classification algorithm
#                  One of...
#                  - "lr"  (Logistic Regression)
#                  - "knn" (k-Nearest Neighbors)
#                  - "nb"  (Naive Bayes)
#                  - "dt"  (Decision Tree)
#                  - "svm" (Support Vector Machine)
#                  - "ada" (Adaptive Boosting)
#                  - "rf"  (Random Forest)
#                  - "nn"  (Neural Network)
# knn.k          : If using knn, the number of neighbors considered
# dt.prune       : If using dt, prune tree (TUE) or not (FALSE)
# svm.tune       : If using svm, tuning (TRUE) or no tuning (FALSE)
# Returns        : probability of response var. being true
#
leon.classify.algorithm_names = c ("lr","knn","nb","dt","svm","ada","rf")
leon.classify = function (
	y_name,
	test,
	train,
	algorithm_name,
	knn.k = 3,
	dt.prune = FALSE,
	svm.tune = FALSE,
	nn.size = 5
) {
	# To remove uncertainty
	set.seed (12345)

	# The formula for prediction models
	formula = eval (parse (text = paste (y_name, "~ .")))

	# The index of the column whose name is the value of y_name
	y_index = which (names (train) == y_name)

	switch (
		algorithm_name,
		lr = {
			model = glm (
				formula = formula,
				family = binomial,
				data = train
			)
			prob = predict (
				object = model,
				newdata = test,
				type = "response"
			)
			prob
		},
		knn = {
			prob = knn (
				train = train [ , - y_index ],
				test  = test  [ , - y_index ],
				cl    = train [ ,   y_index ],
				k     = knn.k,
				prob  = TRUE
			)
			prob = attr (prob, "prob")
			prob
		},
		nb = {
			model = naiveBayes (
				formula = formula,
				data = train
			)
			prob = predict (
				object = model,
				newdata = test,
				type = "raw"
			)
			prob = prob [ , 2 ] / rowSums (prob) # renormalize the prob.
			prob
		},
		dt = {
			model = rpart (
				formula = formula,
				data = train
			)
			if (dt.prune) {
				## you should evaluate different size of tree
				## prune the tree
				model = prune (
					tree = model,
					cp = model $ cptable [
						which.min (model $ cptable [ , "xerror" ]),
						"CP"
					]
				)
			}
			prob = predict (
				object = model,
				newdata = test
			)
			prob
		},
		svm = {
			model = svm (
				formula = formula,
				data = train,
				probability = TRUE
			)
			if (svm.tune) {
				# fine-tune the model with different kernel and params
				## evaluate the range of cost parameter from 0.1 to 10
				tuned = tune.svm (
					formula,
					data = train,
					kernel = "radial",
					cost = 10^(-1:1)
				)
				model = svm (
					formula = formula,
					data = train,
					probability = TRUE,
					kernel = "radial",
					cost = tuned [[ "best.parameters" ]] $ cost
				)
			}
			prob = predict (
				object = model,
				newdata = test,
				probability = TRUE
			)
			prob
		},
		ada = {
			model = ada (
				formula = formula,
				data = train
			)
			prob = predict (
				object = model,
				newdata = test,
				type = "probs"
			)
			prob = prob [ , 2 ] / rowSums (prob)
			prob
		},
		rf = {
			model = randomForest (
				formula = formula,
				data = train
			)
			prob = predict (
				object = model,
				newdata = test,
				type = "response"
			)
			prob
		},
		nn = {
			model = nnet (
				formula = formula,
				data = train,
				size = nn.size,
				na.action = na.omit
			)
			prob = predict (
				object = model,
				newdata = test,
				type = "probs"
			)
			prob
		}
	)
}

# k-fold cross-validation
#
# k           : The number of folds
# All others  : See classify
# Returns     : nothing
#
leon.validate.kfcv = function (
	y_name,
	data,
	algorithm_name,
	k = 10,
	knn.k = 3,
	dt.prune = FALSE,
	svm.tune = FALSE
) {
	# To remove uncertainty
	set.seed(12345)

	n.obs = nrow (data) # no. of observations
	cat (k, "folds using", n.obs, "rows", "\n")
	s = sample (n.obs)
	probs = NULL
	actuals = NULL

	for (fold in 1:k)
	{
		# Row numbers for this fold's test set
		test_i = which (s %% k == (fold - 1))

		cat (
			"Fold", fold,
			"using rows",
			paste0 (test_i, collapse = " "),
			"\n"
		)

		# Training set
		train = data [-test_i, ]

		# Test set
		test = data [ test_i, ]

		prob = leon.classify (
			y_name, test, train, algorithm_name,
			knn.k, dt.prune, svm.tune
		)
		actual = test [[ y_name ]]
		probs = c (probs, prob)
		actuals = c (actuals, actual)
	}

	# plot ROC
	pred = prediction (probs, actuals)
	perf = performance (pred, "tpr", "fpr")
	plot (perf)

	# get other measures by using 'performance'
	get.measure = function (pred, measure.name)
	{
		perf = performance (pred, measure.name)
		m = unlist (slot (perf, "y.values"))
		m
	}

	data.frame (
		Accuracy    = mean (get.measure (pred, "acc" ), na.rm=T),
		Precision   = mean (get.measure (pred, "prec"), na.rm=T),
		Recall      = mean (get.measure (pred, "rec" ), na.rm=T),
		F_measure   = mean (get.measure (pred, "f"   ), na.rm=T),
		Specificity = mean (get.measure (pred, "spec"), na.rm=T),
		AUC         = get.measure (pred, "auc")
	)
}

data.all_VISIT.n.lo = data.all_VISIT.n
data.all_VISIT.n.lo $ POST_FEV1PP_DECLINE  = 0 +
# 	data.all_VISIT.n.lo $ POST_FEV1PP.BASE >  0.88 &
# 	data.all_VISIT.n.lo $ POST_FEV1PP.36MO <= 0.88
	data.all_VISIT.n.lo $ POST_FEV1PP.36MO < 1 *
	data.all_VISIT.n.lo $ POST_FEV1PP.BASE &
	data.all_VISIT.n.lo $ POST_FEV1PP.36 <= 0.88
data.all_VISIT.n.lo = data.all_VISIT.n.lo [ ! names (
	data.all_VISIT.n.lo
) %in% c ("POST_FEV1PP.18MO", "POST_FEV1PP.36MO") ]

data.all_VISIT.n.lo.adam = data.all_VISIT.n.lo
data.all_VISIT.n.lo.adam $ POST_FEV1PP_DECLINE = 0
data.all_VISIT.n.lo.adam $ POST_FEV1PP_DECLINE [
	which (rownames (data.all_VISIT.n.lo) %in% c (
		"4",
		"9",
		"15",
		"16",
		"20",
		"22",
		"25",
		"33",
		"43",
		"47",
		"52",
		"57",
		"60",
		"62",
		"63",
		"73",
		"75",
		"76",
		"77",
		"78",
		"81",
		"86",
		"98",
		"99",
		"104",
		"108",
		"119",
		"132",
		"139",
		"142",
		"146",
		"149",
		"151",
		"154",
		"158",
		"168",
		"178",
		"186",
		"189",
		"193",
		"194",
		"195",
		"196",
		"201",
		"204",
		"205",
		"207",
		"208",
		"213",
		"214",
		"219",
		"225",
		"227",
		"229",
		"234",
		"235",
		"238",
		"240",
		"247",
		"249"
	))
] = 1

data.all_VISIT.n.lo.adam.impr = randomForest(
	formula = POST_FEV1PP_DECLINE ~ .,
	data = as.data.frame(lapply(data.all_VISIT.n.lo.adam,as.numeric)),
	na.action = na.roughfix,
	importance = TRUE
)
varImpPlot(data.all_VISIT.n.lo.adam.impr,main="Predictor importances")
data.all_VISIT.n.lo.adam.imp = importance(data.all_VISIT.n.lo.adam.impr)
write.csv (
	data.all_VISIT.n.lo.adam.imp,
	paste0(outdir,"/data.all_VISIT.n.lo.adam.imp.csv"),
	na=""
)
data.all_VISIT.n.lo.adam = data.all_VISIT.n.lo.adam [ c (
	"POST_FEV1PP_DECLINE",
	rownames (data.all_VISIT.n.lo.adam.imp [
		data.all_VISIT.n.lo.adam.imp[,2] >=
			quantile(data.all_VISIT.n.lo.adam.imp[,2],0.9),
	])
) ]
sort(names(data.all_VISIT.n.lo.adam))
# (imputed_mean_mode & only predictors above 90 percentile %IncMSE)
#  [1] "ANA_PATTERN"          "ATRIP.36MO"           "BMI.18MO"
#  [4] "BMI.36MO"             "CD4.36MO"             "D13YR.18MO"
#  [7] "D13YR.36MO"           "D18YRINH.36MO"        "D18YRINH.BASE"
# [10] "DiastolicDiameter"    "DLCOPP_FINAL.18MO"    "E17_18PNEUM"
# [13] "H1COUGH"              "H3WHEZ"               "IL6"
# [16] "INVIRAS.18MO"         "MMP2_IS"              "PACK_YEARS.18MO"
# [19] "PACK_YEARS.36MO"      "POST_FEV1PP.BASE"     "POST_FEV1PP_DECLINE"
# [22] "RESP.36MO"            "VL_LOG.18MO"          "WAperc_mean_all.36MO"
# [25] "WAperc_mean_lrg.18MO" "WAperc_mean_lrg.36MO" "WAperc_mean_mdm.18MO"
# [28] "WAperc_mean_mdm.36MO"
# (imputed_mean_mode & only predictors above 90 percentile IncNodePurity)
#  [1] "B7HRS.36MO"           "BMI.18MO"             "BMI.36MO"
#  [4] "BNP"                  "BPDIA.36MO"           "BPSYS.36MO"
#  [7] "CD4.36MO"             "CREATININE"           "D18YRINH.36MO"
# [10] "D18YRINH.BASE"        "DiastolicDiameter"    "DLCOPP_FINAL.18MO"
# [13] "DLCOPP_FINAL.BASE"    "H3WHEZ"               "IGE"
# [16] "IL6"                  "IL6_SD"               "IL8"
# [19] "IL8_SD"               "MMP1_PL"              "MMP3_IS"
# [22] "PACK_YEARS.36MO"      "POST_FEV1PP.BASE"     "POST_FEV1PP_DECLINE"
# [25] "SystolicDiameter"     "TRV"                  "WAperc_mean_mdm.18MO"
# [28] "WT.36MO"
# (imputed_medi_mode & only predictors above 90 percentile %IncMSE)
#  [1] "ATRIP.18MO"                 "AZT.BASE"
#  [3] "B7HRS.18MO"                 "B7HRS.36MO"
#  [5] "C2HRSWK.18MO"               "CD4.36MO"
#  [7] "D13YR.18MO"                 "D13YR.36MO"
#  [9] "D18YRINH.36MO"              "D18YRINH.BASE"
# [11] "D1SEP.BASE"                 "DD_Severity"
# [13] "DiastolicDiameter"          "DLCOPP_FINAL.18MO"
# [15] "DLCOPP_FINAL.BASE"          "EjectionFractionUpperLimit"
# [17] "H1COUGH"                    "H3WHEZ"
# [19] "INVIRAS.18MO"               "PACK_YEARS.36MO"
# [21] "POST_FEV1PP.BASE"           "POST_FEV1PP_DECLINE"
# [23] "TRUVADA.36MO"               "WAperc_mean_lrg.36MO"
# [25] "WAperc_mean_mdm.18MO"       "WAperc_mean_mdm.36MO"
# [27] "WAperc_mean_sml.36MO"       "WT.36MO"
# (imputed_medi_mode & only predictors above 90 percentile IncNodePurity)
#  [1] "ARG"                  "BMI.18MO"             "BNP"
#  [4] "BPSYS.36MO"           "CD4.36MO"             "CREATININE"
#  [7] "D18YRINH.36MO"        "D18YRINH.BASE"        "DiastolicDiameter"
# [10] "DLCOPP_FINAL.18MO"    "DLCOPP_FINAL.BASE"    "H3WHEZ"
# [13] "IGE"                  "IL6"                  "IL6_SD"
# [16] "IL8_SD"               "MMP1_PL"              "MMP3_IS"
# [19] "PACK_YEARS.36MO"      "POST_FEV1PP.BASE"     "POST_FEV1PP_DECLINE"
# [22] "RESP.36MO"            "SystolicDiameter"     "TRV"
# [25] "VL_LOG.18MO"          "WAperc_mean_mdm.18MO" "WAperc_mean_sml.18MO"
# [28] "WT.36MO"
# (imputed_missForest & only predictors above 90 percentile %IncMSE)
#  [1] "ANA_PATTERN"          "B7HRS.36MO"           "BMI.36MO"
#  [4] "BNP"                  "BPDIA.BASE"           "D13YR.18MO"
#  [7] "D18YRINH.36MO"        "D18YRINH.BASE"        "DiastolicDiameter"
# [10] "DLCOPP_FINAL.18MO"    "DLCOPP_FINAL.BASE"    "EMTRIV.BASE"
# [13] "frac_910.BASE"        "frac_950.18MO"        "H3WHEZ"
# [16] "IGM_TITER"            "IL6"                  "MMP12_PL"
# [19] "POST_FEV1PP.BASE"     "POST_FEV1PP_DECLINE"  "TEMP.36MO"
# [22] "VL_LOG.18MO"          "WAperc_mean_all.18MO" "WAperc_mean_all.36MO"
# [25] "WAperc_mean_lrg.18MO" "WAperc_mean_lrg.36MO" "WAperc_mean_mdm.36MO"
# [28] "WT.36MO"
# (imputed_missForest & only predictors above 90 percentile IncNodePurity)
#  [1] "ARG"                  "BMI.18MO"             "BNP"
#  [4] "BPDIA.BASE"           "BPSYS.36MO"           "CD4.36MO"
#  [7] "CREATININE"           "D18YRINH.36MO"        "DiastolicDiameter"
# [10] "DLCOPP_FINAL.18MO"    "DLCOPP_FINAL.BASE"    "H3WHEZ"
# [13] "IL6"                  "IL6_SD"               "IL8"
# [16] "IL8_SD"               "MMP1_PL"              "MMP2_IS"
# [19] "POST_FEV1PP.BASE"     "POST_FEV1PP_DECLINE"  "SystolicDiameter"
# [22] "TRV"                  "VL_LOG.18MO"          "WAperc_mean_all.36MO"
# [25] "WAperc_mean_lrg.36MO" "WAperc_mean_mdm.36MO" "WAperc_mean_sml.36MO"
# [28] "WAperc_std_mdm.BASE"

data.all_VISIT.n.lo.adam.cla = data.frame ()

for (temp.algorithm_name in leon.classify.algorithm_names)
{
	png (
		paste0 (
			outdir,
			"/",
			"data.all_VISIT.n.lo.adam",
			".ROC",
			".", temp.algorithm_name,
			".png"
		)
	)
	data.all_VISIT.n.lo.adam.cla = rbind (
		data.all_VISIT.n.lo.adam.cla,
		leon.validate.kfcv (
			"POST_FEV1PP_DECLINE",
			data.all_VISIT.n.lo.adam,
			temp.algorithm_name, dt.prune = TRUE, svm.tune = TRUE
		)
	)
	dev.off()
}

rownames (data.all_VISIT.n.lo.adam.cla) = leon.classify.algorithm_names

write.csv (
	data.all_VISIT.n.lo.adam.cla,
	paste0 (outdir, "/data.all_VISIT.n.lo.adam.cla.csv"),
	na = ""
)



# ----------------------------------------------------------------------- #
#	DIMENSIONALITY REDUCTION
# ----------------------------------------------------------------------- #

do.pca = function(dataset,
                  lbls,
                  filename.screeplot="",
                  filename.scatterplot="",
                  filename.biplot="",
                  filename.loadingplot="")
{
	data.pca = prcomp(dataset, scale=TRUE)
	data.pc = predict(data.pca)

	if(filename.screeplot!="")
	{
		png(paste0(filename.screeplot,".png"))
		plot(data.pca, main="PCA screeplot")
		dev.off()
	}

	if(filename.scatterplot!="")
	{
		png(paste0(filename.scatterplot,".png"))
		plot(data.pc[,1:2], type="n", main="Top 2 PCs scatterplot")
		text(x=data.pc[,1], y=data.pc[,2], labels=lbls)
		dev.off()
	}

	if(filename.biplot!="")
	{
		png(paste0(filename.biplot,".png"))
		biplot(data.pca, main="PCA biplot")
		dev.off()
	}

	if(filename.loadingplot!="")
	{
		png(paste0(filename.loadingplot,".png"))
		plot(data.pca$rotation[,1],type='l', main="Top PC loadingplot")
		#     plot(data.pc[,1],type='l')
		dev.off()
	}

	data.pc
}
do.mds = function(dataset,
                  lbls,
                  filename.scatterplot="")
{
	data.dist = dist(dataset)
	data.mds = cmdscale(data.dist)

	if(filename.scatterplot!="")
	{
		png(paste0(filename.scatterplot,".png"))
		plot(data.mds,type="n",main="MDS scatterplot")
		text(data.mds,labels=lbls)
		dev.off()
	}

	data.mds
}

png(paste0(outdir,"/data.all_VISIT.n.lo.adam.mds.png"))
plot(
	cmdscale(dist(data.all_VISIT.n.lo.adam)),
	main="data.all_VISIT.n.lo.adam MDS scatterplot",
	col=rainbow(2)[1+data.all_VISIT.n.lo.adam$POST_FEV1PP_DECLINE]
)
dev.off()



# ----------------------------------------------------------------------- #
#	CLUSTERING
# ----------------------------------------------------------------------- #

do.kmeans = function(dataset,
                     lbls,
                     k=4)
{
	set.seed(123)
	data.clu = kmeans(dataset, centers=k, nstart=10)
	data.clu$cluster
}
do.hclust = function(dataset,
                     lbls,
                     k=8,
                     hclust.method="average",
                     filename.dendrogram="")
{
	data.dist = dist(dataset)
	hc = hclust(data.dist,method=hclust.method)

	if (filename.dendrogram!="")
	{
		png(paste0(filename.dendrogram,".png"))
		plot(hc,main=paste0("Dendrogram of HC using ",hclust.method,"-link"))
		dev.off()
	}

	hc1 = cutree(hc,k)
	#print(hc1)
	hc1
}
cluster.purity = function(clusters,
                          classes)
{
	sum(apply(table(classes, clusters), 2, max)) / length(clusters)
}
cluster.entropy = function(clusters,
                           classes)
{
	en = function(x)
	{
		s = sum(x)
		sum(sapply(x/s, function(p) {if (p) -p*log2(p) else 0} ) )
	}

	M = table(classes, clusters)
	m = apply(M, 2, en)
	c = colSums(M) / sum(M)
	sum(m*c)
}

# clu1 = do.kmeans(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=4)
# clu2 = do.kmeans(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=8)
# clu3 = do.hclust(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=4,"single","dr_clu/data.all_VISIT.n.hclust.single.dendro")
# clu4 = do.hclust(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=8,"single")
# clu5 = do.hclust(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=4,"complete","dr_clu/data.all_VISIT.n.hclust.complete.dendro")
# clu6 = do.hclust(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=8,"complete")
# clu7 = do.hclust(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=4,"average","dr_clu/data.all_VISIT.n.hclust.average.dendro")
# clu8 = do.hclust(data.all_VISIT.n.lo.adam,rownames(data.all_VISIT.n.lo.adam),k=8,"average")
# palette = rainbow(8)
# png("dr_clu/data.all_VISIT.mds.scatter.kmeans.4.png")
# plot(mds,type="n",main="MDS scatterplot with 4-means clustering")
# text(mds,labels,col=palette[clu1])
# dev.off()
# png("dr_clu/data.all_VISIT.mds.scatter.kmeans.8.png")
# plot(mds,type="n",main="MDS scatterplot with 8-means clustering")
# text(mds,labels,col=palette[clu2])
# dev.off()
# png("dr_clu/data.all_VISIT.mds.scatter.hclust.single.4.png")
# plot(mds,type="n",main="MDS scatterplot with single-link hierarchical clustering cut into 4 groups")
# text(mds,labels,col=palette[clu3])
# dev.off()
# png("dr_clu/data.all_VISIT.mds.scatter.hclust.single.8.png")
# plot(mds,type="n",main="MDS scatterplot with single-link hierarchical clustering cut into 8 groups")
# text(mds,labels,col=palette[clu4])
# dev.off()
# png("dr_clu/data.all_VISIT.mds.scatter.hclust.complete.4.png")
# plot(mds,type="n",main="MDS scatterplot with complete-link hierarchical clustering cut into 4 groups")
# text(mds,labels,col=palette[clu5])
# dev.off()
# png("dr_clu/data.all_VISIT.mds.scatter.hclust.complete.8.png")
# plot(mds,type="n",main="MDS scatterplot with complete-link hierarchical clustering cut into 8 groups")
# text(mds,labels,col=palette[clu6])
# dev.off()
# png("dr_clu/data.all_VISIT.mds.scatter.hclust.average.4.png")
# plot(mds,type="n",main="MDS scatterplot with average-link hierarchical clustering cut into 4 groups")
# text(mds,labels,col=palette[clu7])
# dev.off()
# png("dr_clu/data.all_VISIT.mds.scatter.hclust.average.8.png")
# plot(mds,type="n",main="MDS scatterplot with average-link hierarchical clustering cut into 8 groups")
# text(mds,labels,col=palette[clu8])
# dev.off()



## Non-base functions used:
#
# stats::reshape
# utils::read.csv
# utils::write.csv
#

## Searches & references
#
# https://en.wikipedia.org/wiki/Level_of_measurement
#
# https://encrypted.google.com/search?q=r+long+to+wide
# UCLA → Institute for Digital Research and Education → Research Technology Group → Statistical Consulting Group
# R FAQ: How can I reshape my data in R?
# http://www.ats.ucla.edu/stat/r/faq/reshape.htm
#
# https://encrypted.google.com/search?q=r+percent+na
# http://r.789695.n4.nabble.com/deleting-columns-from-a-dataframe-where-NA-is-more-than-15-percent-of-the-column-length-td4639237.html
