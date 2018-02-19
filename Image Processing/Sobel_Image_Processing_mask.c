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
		nom_ecr[]="resultat_borders.pgm" ;
    int		largeur, hauteur ;

    FILE	*fp_lec, *fp_ecr ;
    register int l, c ;
    pixel	*ligne[3], *ligne_res, *tmp ;

#define READ_LINE(buffer)						\
    if ( fread (buffer, sizeof(pixel), largeur, fp_lec) != largeur )	\
			{ perror(nom_lec); exit(1); }

#define WRITE_LINE(buffer)						\
    if ( fwrite (buffer, sizeof(pixel), largeur, fp_ecr) != largeur )	\
			{ perror(nom_ecr); exit(1); }

    //open read and write files
    open_r (&fp_lec, nom_lec, &largeur, &hauteur) ;
    open_w (&fp_ecr, nom_ecr,  largeur,  hauteur) ;

    //malloc space for 4 lines of the image an define pointers to each
    ligne[0] = (pixel*) malloc ( sizeof(pixel) * largeur * 4 ) ;
    if (!ligne[0])	{ perror ("Memoire insuffisante"); exit(1); }

    ligne[1]  = ligne[0] + ( sizeof(pixel) * largeur ) ;
    ligne[2]  = ligne[1] + ( sizeof(pixel) * largeur ) ;
    ligne_res = ligne[2] + ( sizeof(pixel) * largeur ) ;

    //read first two lines of the three from file into memory
    READ_LINE (ligne[0]) ;
    READ_LINE (ligne[1]) ;

    int deltaX, deltaY ;
    float normL1, normL2 ;

    //iterate over rows
    for	(l=0; l<hauteur; l++)
    {
      //read second line (the new row of pixels from the image)
    	READ_LINE (ligne[2]) ;

      // iterate over cols (all pixels in the line)
    	for (c=0 ; c<largeur ; c++)
    	{
        //if top row
        if (l==0) {
          //if top left corner
          if (c==0) {
        	  deltaX = (2 * ligne[1+1][c+1])  + (2 * ligne[l][c+1]) - (2 * ligne[1+1][c]) -(2 * ligne[1][c]) ; 
            deltaY = (2 * ligne[1+1][c])  + (2 * ligne[l+1][c+1]) - (2 * ligne[1][c]) -(2 * ligne[1][c+1]) ; 
          }
          //if top right corner
          else if (c==largeur-1) {
        	  deltaX = (2 * ligne[1+1][c+1])  + (2 * ligne[l][c+1]) - (2 * ligne[1+1][c]) -(2 * ligne[1][c]) ; 
            deltaY = (2 * ligne[1+1][c])  + (2 * ligne[l+1][c+1]) - (2 * ligne[1][c]) - (2 * ligne[1][c+1]) ; 
          }
          //else (other top row)
          else {
            deltaX = (2 * ligne[1][c+1]) + (2 * ligne[1-1][c+1]) - (2 * ligne[1][c-1]) - (2 * ligne[1-1][c-1]) ;
            deltaY = ligne[1-1][c-1] + (2 * ligne[1-1][c]) + ligne[1-1][c+1] - ligne[1][c-1] - (2 * ligne[1][c]) - ligne[1+1][c] ; 
          }
        }
        //if bottom row
        else if (l==hauteur-1) {
          //if bottom left corner
          if (c==0) {
            deltaX = (2 * ligne[1-1][c+1])  + (2 * ligne[l][c+1]) - (2 * ligne[1-1][c]) - (2 * ligne[1][c]) ; 
            deltaY = (2 * ligne[1-1][c])  + (2 * ligne[l-1][c+1]) - (2 * ligne[1][c]) - (2 * ligne[1][c+1]) ;            
          }
          //if c=largeur (bottom right corner)
          else if (c==largeur-1) {
        	  deltaX = (2 * ligne[1][c])  + (2 * ligne[l+1][c]) - (2 * ligne[1][c-1]) - (2 * ligne[1+1][c-1]) ; 
            deltaY = (2 * ligne[1][c-1])  + (2 * ligne[l][c]) - (2 * ligne[1+1][c-1]) - (2 * ligne[1+1][c]) ; 
          }
          //else (other bottom row)
          else {
            deltaX = (2 * ligne[1][c+1]) + (2 * ligne[1+1][c+1]) - (2 * ligne[1][c-1]) - (2 * ligne[1+1][c-1]) ;
            deltaY = ligne[1-1][c-1] + (2 * ligne[1-1][c]) + ligne[1-1][c+1] - ligne[1][c-1] - (2 * ligne[1][c]) - ligne[1+1][c] ; 
          }
        }
        //if other left edge
        else if (c==0) {
        	deltaX = (2 * ligne[1][c+1]) + (1 * ligne[1+1][c+1]) + (1 * ligne[1-1][c+1]) - (2 * ligne[1][c]) - (1 * ligne[1+1][c]) - (1 * ligne[1-1][c]) ;
          deltaY = (2 * ligne[1-1][c+1]) + (2 * ligne[1-1][c]) + ligne[1-1][c+1] - (2 * ligne[1+1][c+1]) - (2 * ligne[1+1][c]) ;           
        }
        //if other right edge
        else if (c==largeur-1) {
          deltaX = (2 * ligne[1][c-1]) + (1 * ligne[1+1][c-1]) + (1 * ligne[1-1][c-1]) - (2 * ligne[1][c]) - (1 * ligne[1+1][c]) - (1 * ligne[1-1][c]) ;
          deltaY = (2 * ligne[1-1][c-1]) + (2 * ligne[1-1][c]) + ligne[1-1][c-1] - (2 * ligne[1+1][c-1]) - (2 * ligne[1+1][c]) ; 
        }
        //else (not on any edge/corner) - lines from previous class
        else {
          deltaX = ligne[1+1][c+1] + (2 * ligne[1][c+1]) + ligne[1-1][c+1] - ligne[1+1][c-1] - (2 * ligne[1][c-1]) - ligne[1-1][c-1] ;
          deltaY = ligne[1+1][c+1] + (2 * ligne[1+1][c]) + ligne[1+1][c-1] - ligne[1-1][c+1] - (2 * ligne[1-1][c]) - ligne[1-1][c-1] ; 
        }
        
        // calc the L1 and L2 norms
        normL1 = (abs(deltaX) + abs(deltaY)) / 6 ;
        normL2 = (sqrt(pow(deltaX, 2) + pow(deltaY, 2))) / 4 ;

        // add norm to list
        // ligne_res[c] = normL1 ;
        ligne_res[c] = normL2 ;
    	}

      //write the res line to the output file
      WRITE_LINE (ligne_res) ;

      //update all pointer by one, so they shunt forwards one place before treating the next row
      //this permutes the pointers in a cyclical fashion (so two rows shunt forwards, and last line becomes the first)
      //we do this so we can only use 3 buffers. The buffer that holds the top row becomes the buffer that holds the newly read line.
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
