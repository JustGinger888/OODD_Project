/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.solent.com528.project.model.dto;

/**
 *
 * @author ethan
 */
public class CreditCardValidityCalculator {
    
   public static boolean numberCheck(long cardNum) {
      return validitychk(cardNum);
   }
   
   public static boolean validitychk(long cardNum) {
      return (thesize(cardNum) >= 13 && thesize(cardNum) <= 16) && (prefixmatch(cardNum, 4)
         || prefixmatch(cardNum, 5) || prefixmatch(cardNum, 37) || prefixmatch(cardNum, 6))
         && ((sumdoubleeven(cardNum) + sumodd(cardNum)) % 10 == 0);
   }
   
   public static int sumdoubleeven(long cardNum) {
      int sum = 0;
      String num = cardNum + "";
      for (int i = thesize(cardNum) - 2; i >= 0; i -= 2)
         sum += getDigit(Integer.parseInt(num.charAt(i) + "") * 2);
      return sum;
   }
   
   public static int getDigit(int cardNum) {
      if (cardNum < 9)
         return cardNum;
      return cardNum / 10 + cardNum % 10;
   }
   
   public static int sumodd(long cardNum) {
      int sum = 0;
      String num = cardNum + "";
      for (int i = thesize(cardNum) - 1; i >= 0; i -= 2)
         sum += Integer.parseInt(num.charAt(i) + "");
      return sum;
   }
   
   public static boolean prefixmatch(long cardNum, int d) {
      return getprefx(cardNum, thesize(d)) == d;
   }
   
   public static int thesize(long d) {
      String num = d + "";
      return num.length();
   }
   
   public static long getprefx(long cardNum, int k) {
      if (thesize(cardNum) > k) {
         String num = cardNum + "";
         return Long.parseLong(num.substring(0, k));
      }
      return cardNum;
   }
}
