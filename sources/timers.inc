* =============== I N C L U D E   F I L E ===================================
* ===========================================================================
* =============== Equates for delay loop constants ==========================
* ===========================================================================
*
* ===========================================================================
* Created by Sophie Dexter
* Version 1.0
* 17-Jul-2012
* ===========================================================================
*
* I use software delay loops to wait for short periods of time when necessary
* I worked out these values by first using large numbers and multiple delays 
* and timing how long they took using my watch then simply dividing down to
* get the required loop count values
*
Count_10ms		EQU	22000				* 22,001 loops x 0.48 = 10.56 ms
Count_10us		EQU	21					* 22 loops x 0.48 = 10.56 us
Count_6us		EQU	12					* 13 loops x 0.48 = 6.24 us
*
* ===========================================================================
