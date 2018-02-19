/*	NOMS DU BINOME :
 *
 *	model.c : Terminez ce modele de programme pour realiser l'operateur demande.
 *	Compilation :	make nom_du_programme
 *	Patrick Horain - TSP/EPH - le 9/02/11.
 *
 *---------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>


typedef unsigned char pixel ;

static void open_r (FILE **fp, char *nomfic, int *largeur, int *hauteur)
{   int maxval ;

    if (! (*fp = fopen(nomfic,"r")) )	{ perror(nomfic);  exit(1); }
    if ( getc(*fp)!='P' || getc(*fp)!='5' || ! isspace(getc(*fp)) ) {
	fprintf (stderr, "%s n'est pas au format PGM binaire (P5).\n",
							nomfic) ;
	exit(1) ;
    }
    fscanf  (*fp, "%d %d %d ", largeur, hauteur, &maxval) ;
}

static void open_w (FILE **fp, char *nomfic, int largeur, int hauteur)
{   if (! (*fp = fopen(nomfic,"w")) )	{ perror(nomfic);  exit(1); }
    fprintf (*fp, "P5 %d %d 255\n", largeur, hauteur) ;
}

/*---------------------------------------------------------------------*/
int main ()
{
    char	nom_lec[]="lacornou.pgm",
		nom_ecr[]="resultat_optim.pgm" ;
    int		largeur, hauteur ;

    FILE	*fp_lec, *fp_ecr ;
    register int l, c ;
    pixel	*ligne[3], *ligne_res, *tmp ;
     // *ligne_colsum,

#define READ_LINE(buffer)						\
    if ( fread (buffer, sizeof(pixel), largeur, fp_lec) != largeur )	\
			{ perror(nom_lec); exit(1); }

#define WRITE_LINE(buffer)						\
    if ( fwrite (buffer, sizeof(pixel), largeur, fp_ecr) != largeur )	\
			{ perror(nom_ecr); exit(1); }

    //open read and write files
    open_r (&fp_lec, nom_lec, &largeur, &hauteur) ;
    open_w (&fp_ecr, nom_ecr,  largeur,  hauteur) ;

    //malloc space for 5 lines of the image an define pointers to each
    ligne[0] = (pixel*) malloc ( sizeof(pixel) * largeur * 4 ) ;
    if (!ligne[0])	{ perror ("Memoire insuffisante"); exit(1); }

    ligne[1]  = ligne[0] + ( sizeof(pixel) * largeur ) ;
    ligne[2]  = ligne[1] + ( sizeof(pixel) * largeur ) ;
    ligne_res = ligne[2] + ( sizeof(pixel) * largeur ) ;
    
    //create an array to hold the summation of columns
    int ligne_colsum[largeur];

    //read first two lines of the three from file into memory
    READ_LINE (ligne[0]) ;
    READ_LINE (ligne[1]) ;

    //iterate over rows (don't do first and last)
    for	(l=1; l<hauteur-1; l++)
    {
      //read second line (the new row of pixels from the image)
    	READ_LINE (ligne[2]) ;
      
      //sum the 3 lines column-wise and put result in ligne_colsum
      //2 additions per pixel
    	for (c=0 ; c<largeur ; c++)
    	{
        ligne_colsum[c] = ligne[0][c] + ligne[1][c] + ligne[2][c] ;
    	}
      
      //for each element of vector, sum it with the two following elements (don't do edges)
      //2 additions per pixel
      for (c=1 ; c<largeur-1 ; c++)
      {
        ligne_res[c] = (ligne_colsum[c-1] + ligne_colsum[c] + ligne_colsum[c+1]) / 9 ;
      }

      //write the res line to the output file
    	WRITE_LINE (ligne_res) ;
      
      //update all pointer by one, so they shunt forwards one place before treating the next row
      //this permutes the pointers in a cyclical fashion
      //save line0 pointer
    	tmp	=ligne[0] ;
      //shift pointer up
    	ligne[0]=ligne[1] ;
      //shift pointer up
    	ligne[1]=ligne[2] ;
      //copy line0 pointer into line2
    	ligne[2]=tmp ;
    }
    
    exit(0) ;
}
