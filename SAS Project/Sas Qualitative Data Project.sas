/* ******************************************** */
/* DATA IMPORT STATEMENTS */
/* ******************************************** */

/* import the datafile student-mat */
FILENAME CSV "/folders/myfolders/Project/student-mat-g3kmeans.csv" TERMSTR=LF;
proc import datafile=CSV
			out=work.student_mat
			dbms=csv
			replace;
run;
/* get rid of the VAR1 column that kmeans introduces */
DATA student_mat(DROP = VAR1); 
SET student_mat;
RUN;


/* import the datafile treecluster */
FILENAME CSV "/folders/myfolders/Project/TREE_cluster.csv" TERMSTR=LF;
proc import datafile=CSV
			out=work.treecluster
			dbms=csv
			replace;
run;
/* get rid of the VAR1 column that kmeans introduces */
DATA treecluster(DROP = VAR3); 
SET treecluster;
RUN;


/* import the datafile mca_output */
FILENAME CSV "/folders/myfolders/Project/MCA_OUTPUT_dim1to43.csv" TERMSTR=LF;
proc import datafile=CSV
			out=work.mca_output
			dbms=csv
			replace;
run;


/* import the datafile fakedata */
FILENAME CSV "/folders/myfolders/Project/fakedata.csv" TERMSTR=LF;
proc import datafile=CSV
			out=work.fakedata
			dbms=csv
			replace;
run;

/* ******************************************** */
/* MACRO STATEMENTS */
/* ******************************************** */

/* define 'threepanel' template that displays a histogram, box plot, and Q-Q plot */
proc template;
define statgraph threepanel;
dynamic _X _QUANTILE _Title _mu _sigma;
begingraph;
   entrytitle halign=center _Title;
   layout lattice / rowdatarange=data columndatarange=union 
      columns=1 rowgutter=5 rowweights=(0.4 0.10 0.5);
      layout overlay;
         histogram   _X / name='histogram' binaxis=false;
         densityplot _X / name='Normal' normal();
         densityplot _X / name='Kernel' kernel() lineattrs=GraphData2(thickness=2 );
         discretelegend 'Normal' 'Kernel' / border=true halign=right valign=top location=inside across=1;
      endlayout;
      layout overlay;
         boxplot y=_X / boxwidth=0.8 orient=horizontal;
      endlayout;
      layout overlay;
         scatterplot x=_X y=_QUANTILE;
         lineparm x=_mu y=0.0 slope=eval(1./_sigma) / extend=true clip=true;
      endlayout;
      columnaxes;
         columnaxis;
      endcolumnaxes;
   endlayout;
endgraph;
end;
run;


/* Macro to create a three-panel display that shows the 
   distribution of data and compares the distribution to a normal
   distribution. The arguments are 
   DSName = name of SAS data set
   Var    = name of variable in the data set.
   The macro calls the SGRENDER procedure to produce a plot
   that is defined by the 'threepanel' template. The plot includes
   1) A histogram with a normal and kernel density overlay
   2) A box plot
   3) A normal Q-Q plot

   Example calling sequence:
   ods graphics on;
   %ThreePanel(sashelp.cars, MPG_City)
   %ThreePanel(sashelp.iris, SepalLength)

   For details, see
   http://blogs.sas.com/content/iml/2013/05/08/three-panel-visualization/
*/
%macro ThreePanel(DSName, Var);
   %local mu sigma;

   /* 1. sort copy of data */
   proc sort data=&DSName out=_MyData(keep=&Var);
      by &Var;
   run;

   /* 2. Use PROC UNIVARIATE to create Q-Q plot 
         and parameter estimates */
   ods exclude all;
   proc univariate data=_MyData;
      var &Var;
      histogram &Var / normal; /* create ParameterEstimates table */
      qqplot    &Var / normal; 
      ods output ParameterEstimates=_PE QQPlot=_QQ(keep=Quantile Data rename=(Data=&Var));
   run;
   ods exclude none;

   /* 3. Merge quantiles with data */
   data _MyData;
   merge _MyData _QQ;
   label Quantile = "Normal Quantile";
   run;

   /* 4. Get parameter estimates into macro vars */
   data _null_;
   set _PE;
   if Symbol="Mu"    then call symputx("mu", Estimate);
   if Symbol="Sigma" then call symputx("sigma", Estimate);
   run;

   proc sgrender data=_MyData template=threepanel;
   dynamic _X="&Var" _QUANTILE="Quantile" _mu="&mu" _sigma="&sigma"
          _title="Distribution of &Var";
   run;
%mend;


/* macro to loop through a list and execute the univariate function and threepanel macro on each element */
/* @AUTHOR: CARL ROBINSON */
%macro loop_univariate(list1);
	%local i var1;
	%do i=1 %to %sysfunc(countw(&list1,,s));
	%let var1=%scan(&list1,&i,,s);
	/* 	seems we can only run univariate on quantitative data.. */
	proc univariate data=student_mat;
	var &var1;
	run;
	ods graphics on;
	ods listing gpath="/folders/myfolders/Project/image_out";
	%ThreePanel(student_mat, &var1)
	%end;
%mend loop_univariate;


/* macro to loop through a list and execute the sgplot function on each element */
/* @AUTHOR: CARL ROBINSON */
%macro loop_sgplot(list1);
	ods graphics on;
	ods listing gpath="/folders/myfolders/Project/image_out";
	%local i var1;
	%do i=1 %to %sysfunc(countw(&list1,,s));
	%let var1=%scan(&list1,&i,,s);
		title &var1;
		proc sgplot data=student_mat;
		vbar &var1 / stat=percent;
		run;
	%end;
	ods graphics off;
%mend loop_sgplot;


/* macro to loop through a list and plot freq with target var on each element */
/* @AUTHOR: CARL ROBINSON */
%macro loop_dotplot(list1);
	ods graphics on;
	ods listing gpath="/folders/myfolders/Project/image_out";
	%local i var1;
	%do i=1 %to %sysfunc(countw(&list1,,s));
	%let var1=%scan(&list1,&i,,s);
		proc freq data=student_mat;
		   tables G3_bin*&var1 / plots=freqplot(type=dot scale=percent);
		run;
	%end;
	ods graphics off;
%mend loop_dotplot;

/* ******************************************** */
/* UNIDIMENSIONAL ANALYSIS STATEMENTS */
/* ******************************************** */

/* display the list of variables and their data type */
proc contents data=student_mat position ;
run;
/* display more information on each of the of variables */
PROC FREQ DATA=student_mat nlevels;
RUN;


/* run macro to plot univariate stats and three panel plot for quant vars */
%loop_univariate(age failures absences G3);


/* use macro to plot univariate stats and three panel plot for quant vars */
%loop_sgplot(Age_bin Failures_bin Absences_bin G3_bin);
%loop_sgplot(Medu Fedu traveltime studytime famrel freetime goout Dalc Walc health);
%loop_sgplot(school sex address famsize Pstatus Mjob Fjob reason guardian);
%loop_sgplot(schoolsup famsup paid activities nursery higher internet romantic);

/* ******************************************** */
/* BIDIMENSIONAL ANALYSIS STATEMENTS */
/* ******************************************** */

/* calc chi-squared of all variables with target variable */
proc freq data=student_mat;
table G3_bin*_ALL_ /expected cellchi2  chisq; *CHISQ FAIT LES TESTS;
run;


/* use macro to plot freq dotplots with target var on each element  */
%loop_dotplot(Medu Failures_bin schoolsup paid higher Absences_bin);


/* get frequency table and univar stats for target variable G3_bin */
proc freq data=student_mat;
table G3_bin;
run;
title 'G3';
proc univariate data=student_mat noprint;
   histogram G3_bin;
run;


/* plot scatter plot between target variable and categorical variable, to help determine
direction of correlation*/
ods graphics on;
title 'Direction of correlation';
proc corr data=student_mat nomiss plots=matrix(histogram);
   var G3_bin schoolsup;
 run;
ods graphics off;


/* frequency table between two cat vars (tri-croisé) */
proc freq data=student_mat;
TABLES G3_bin*schoolsup;
run;


/* ******************************************** */
/* MULTIDIMENSIONAL ANALYSIS STATEMENTS */
/* ******************************************** */

/* run multiple correspondence analysis on all variables over 43 dimensions, and save coefficients */
ods graphics on / width=12in height=12in;
ods graphics on;
ods listing gpath="/folders/myfolders/Project/image_out";
/* proc corresp data=student_mat mca short outc=mca_output; */
proc corresp data=student_mat binary dim=43 noprint outc=mca_output;
tables G3_bin Age_bin Failures_bin Absences_bin Medu Fedu traveltime studytime famrel freetime goout Dalc Walc health school sex address famsize Pstatus Mjob Fjob reason guardian schoolsup famsup paid activities nursery higher internet romantic;
supplementary G3_bin;
run;
ods graphics off;


/* sort and print the output of MCA by interia, to determine how many dimensions comprise */
/* 80% of the inertia */
proc sort data=mca_output out=sorted;	
   by descending inertia;
run;
proc print data=sorted(keep = _NAME_ inertia);
run;


/* prepare the input data for discriminant analysis */
/* extract the coefficients across 43 dimensions for all observations */
data mca_output_dims; set mca_output;
keep dim1-dim43;
if _TYPE_ ='OBS';
run;
/* get target variable */
data target;
set student_mat;
keep G3_bin;
run;
/* merge coefficients and target variable to create input table for discrim */
data discrim_input;
merge target mca_output_dims;
run;


/* run stepdisc to discriminate iteratively */
PROC STEPDISC DATA=discrim_input  fw; * OPTION ASCENDANTE FOWARD;
class G3_bin;
var dim1-dim43;
run;


/* run canonical discriminant factor analysis */
proc candisc data=discrim_input ncan=3 out=outcan;
class G3_bin;
/* var dim1 dim4 dim43 dim7 dim33 dim21 dim35 dim24 dim40 dim9 dim42 dim8 dim32 dim38; */
var dim1-dim43;
run;


/* run discriminant factor analysis with fake test data for contour plot*/
proc discrim data=discrim_input testdata=fakedata testout=fake_out out=discrim_out canonical;
	class G3_bin;
	/* var dim1 dim4 dim43 dim7 dim33 dim21 dim35 dim24 dim40 dim9 dim42 dim8 dim32 dim38; */
	var dim1-dim43;
run;


/* merge fakedata and real results from discriminant analysis */
data plotclass;
  merge fake_out discrim_out;
run;


/* scatter plot template */
proc template;
   define statgraph scatter;
      begingraph / attrpriority=none;
         entrytitle 'Student Grade Data';
         layout overlayequated / equatetype=fit
            xaxisopts=(label='Canonical Variable 1')
            yaxisopts=(label='Canonical Variable 2');
            scatterplot x=Can1 y=Can2 / group=G3_bin name='Grade'
                                        markerattrs=(size=6px);
            layout gridded / autoalign=(topright);
               discretelegend 'Grade' / border=false opaque=false;
            endlayout;
         endlayout;
      endgraph;
   end;
run;


/* draw scatter plot of individuals in canonical variables 1 and 2 */
ods graphics on / width=10in height=8in;
ods listing gpath="/folders/myfolders/Project/image_out";
	proc sgrender data=discrim_out template=scatter;
	run;
ods graphics off;


/* contour plot template */
proc template;
  define statgraph classify;
    begingraph;
      layout overlay / cycleattrs=true;
        contourplotparm x=Can1 y=Can2 z=_into_ / contourtype=fill  
						 nhint = 30 gridded = false Colormodel=(lightblue pink lightgreen);
        scatterplot x=Can1 y=Can2 / group=G3_bin name='Grade'
                                        markerattrs=(size=6px);
       	discretelegend 'Grade' / border=false opaque=false;
      endlayout;
    endgraph;
  end;
run;

/* data conversion of qual target variable into quant variable for use with sgrender */
data plotclass;
  set plotclass;
  _INTO_=tranwrd(_INTO_,'G3_a_zero',0);
  _INTO_=tranwrd(_INTO_,'G3_b_low',1);
  _INTO_=tranwrd(_INTO_,'G3_c_intermediate',2);
  _INTO_=tranwrd(_INTO_,'G3_d_high',3);
run;
data plotclass;
  set plotclass(rename=_INTO_=_INTO_old);
  _INTO_=input(_INTO_old,best12.);
run;


/* plot contour plot */
ods graphics on / width=10in height=8in;
ods listing gpath="/folders/myfolders/Project/image_out";
proc sgrender data = plotclass template = classify;
run;
ods graphics off;


/* kppv crossvalidated clustering */
proc discrim data=discrim_input method=npar K=3 crossvalidate out=kppv_out outcross=kppv_out_cross; 
	class G3_bin;
	var dim1-dim43;
run;
/* tri-croisé of kppv output */
proc freq data=kppv_out_cross;
     table G3_bin*_INTO_;
run;


/* run CAH with ward criteria */
ods graphics on;
proc cluster PLOTS(MAXPOINTS=400) data=discrim_input method=ward outtree=dendrogram ;
	var dim1-dim43;
run;


/* plot the dendrogram */
proc tree data=dendrogram out=tree nclusters=4 ;
COPY dim1 dim2 dim3;
run;


/* scatter plot with cluster colours */
proc sgplot data=tree;
   scatter y=dim2 x=dim1 / group=cluster;
   styleattrs datasymbols=(circlefilled trianglefilled squarefilled starfilled);
run;
ods graphics off;


/* CAH scatter plot with cluster colours */
proc sgplot data=tree;
   scatter y=dim3 x=dim1 / group=cluster;
   styleattrs datasymbols=(circlefilled trianglefilled squarefilled starfilled);
run;
ods graphics off;


/* get frequency counts of each dendrogram cluster crossed with target variable */
proc freq data=treecluster;
TABLES G3_bin*cluster / out=freqs;
run;


/* for each cluster plot histogram showing cluster membership of target variable categories */
proc sgpanel data=freqs;
panelby cluster / onepanel noborder layout=columnlattice;
vbar G3_bin / response=PERCENT;
run;
