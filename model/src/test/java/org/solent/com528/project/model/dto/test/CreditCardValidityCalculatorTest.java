
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.solent.com528.project.model.dto.test;



import org.junit.Assert;
import org.junit.Test;
import org.solent.com528.project.model.dto.CreditCardValidityCalculator;

public class CreditCardValidityCalculatorTest {

    @Test
    public void testreditCardValidity() {

        CreditCardValidityCalculator creditCardValidityCalculator = new CreditCardValidityCalculator();
        Assert.assertTrue(creditCardValidityCalculator.numberCheck(4440967484181607L));
        
        Assert.assertFalse(creditCardValidityCalculator.numberCheck(4440967484181627L));
        
    }
}
