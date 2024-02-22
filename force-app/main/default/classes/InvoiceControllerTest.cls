@isTest
private class InvoiceControllerTest {
    
    @isTest
    static void saveTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        // Need to set the payment terms from the account for Testing once that is completed
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    

        Test.startTest();
            PageReference testPR = invExt.save();
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id FROM Invoice__c];

        // Automation currently set to generate 4 invoices - but this will change soon.
        Assert.areEqual(4, invListCheck.size(), 'Invoice List Size does not match 4.');

    }

    @isTest
    static void cancelTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        Invoice__c testInvoice = new Invoice__c();
        testInvoice.Opportunity__c = o.Id;
        testInvoice.Account__c = o.AccountId;
        testInvoice.Amount__c = o.Amount;
        testInvoice.Due_Date__c = o.CloseDate + 90;

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    
        invExt.newInvoices.add(testInvoice);

        Test.startTest();
            PageReference testPR = invExt.cancel();
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id FROM Invoice__c];
        
        Assert.areEqual(0, invListCheck.size(), 'Invoice List Size does not match 0.');

    }

    @isTest
    static void deletePostiveTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        Invoice__c testInvoice = new Invoice__c();
        testInvoice.Opportunity__c = o.Id;
        testInvoice.Account__c = o.AccountId;
        testInvoice.Amount__c = 1233;
        testInvoice.Due_Date__c = o.CloseDate + 90;
        testInvoice.Paid__c = false;
        insert testInvoice;

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    

        // Set Insewrted, Unpaid invoice to 0 amount so it will be deleted.
        for(Invoice__c i : invExt.newInvoices){
            if(i.Amount__c == 1233.00){
                i.Amount__c = 0;
            }
        }

        Test.startTest();
            PageReference testPR = invExt.save();
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id, Amount__c, Paid__c FROM Invoice__c];   

        // If only 3 invoices are created, the 1 with the 0 amount was deleted.
        Assert.areEqual(3, invListCheck.size(), 'Invoice List Size does not match 3.');

    }

    @isTest
    static void deleteNegativeTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        Invoice__c testInvoice = new Invoice__c();
        testInvoice.Opportunity__c = o.Id;
        testInvoice.Account__c = o.AccountId;
        testInvoice.Amount__c = 1233;
        testInvoice.Due_Date__c = o.CloseDate + 90;
        testInvoice.Paid__c = true;
        insert testInvoice;

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    

        // Set Inserted, Unpaid invoice to 0 amount to see if it will be deleted.
        for(Invoice__c i : invExt.newInvoices){
            if(i.Amount__c == 1233.00){
                i.Amount__c = 0;
            }
        }

        Test.startTest();
            PageReference testPR = invExt.save();
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id, Amount__c, Paid__c FROM Invoice__c];   
        
        // Should still make 4 invoices, inserted and PAID invoice should not be deleted.
        // TODO Update this to verify Error message once Error Message code is done
        Assert.areEqual(4, invListCheck.size(), 'Invoice List Size does not match 4.');

    }

    @isTest
    static void gotoMonthlyInvoiceTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    

        Test.startTest();
            invExt.showMonthly();
            PageReference testPR = invExt.save();
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id, Amount__c, Paid__c FROM Invoice__c];   
        
        // Should make 12 invoices
        Assert.areEqual(12, invListCheck.size(), 'Invoice List Size does not match 12.');

    }

    @isTest
    static void gotoQuarterlyInvoiceTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    

        Test.startTest();
            // Since Quarterly is the current Default, switch to Monthly and back to Quarterly
            invExt.showMonthly();
            invExt.showQuarterly();
            PageReference testPR = invExt.save();
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id, Amount__c, Paid__c FROM Invoice__c];   
        
        // Should still make 4 invoices, inserted and PAID invoice should not be deleted.
        Assert.areEqual(4, invListCheck.size(), 'Invoice List Size does not match 4.');

    }

    @isTest
    static void saveWithNoPreviousInvoiceTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        // Need to set the payment terms from the account for Testing once that is completed
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        List<Invoice__c> invListFromTrigger = [SELECT Id FROM Invoice__c WHERE Opportunity__c =: o.Id];
        delete invListFromTrigger;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    

        Test.startTest();
            PageReference testPR = invExt.save();
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id FROM Invoice__c];

        // Automation currently set to generate 4 invoices - but this will change soon.
        Assert.areEqual(4, invListCheck.size(), 'Invoice List Size does not match 4.');

    }

    @isTest
    static void checkNULLInvoiceAmountTest(){

        // Data Setup
        List<Account> accList = TestDataFactory.createAcc(1);
        insert accList;

        List<Opportunity> testOpp = new List<Opportunity>();
        Opportunity o = TestDataFactory.createOpp(accList[0]);
        o.StageName = 'Closed Lost';
        insert o;

        ApexPages.StandardSetController testSSC = new ApexPages.StandardSetController(new List<Opportunity>{o});

        // One Inserted invoice with NULL amount will be set to 0;
        Invoice__c testInvoice = new Invoice__c();
        testInvoice.Opportunity__c = o.Id;
        testInvoice.Account__c = o.AccountId;
        testInvoice.Amount__c = NULL;
        testInvoice.Due_Date__c = o.CloseDate + 90;
        testInvoice.Paid__c = true;
        insert testInvoice;

        PageReference testPage = new PageReference('/');        
        Test.setCurrentPage(testPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
        
        InvoiceController invExt = new InvoiceController(testSSC);    

        Test.startTest(); 
            PageReference testPR = invExt.save();        
        Test.stopTest();

        // Asserts
        Assert.areEqual('/'+o.Id, testPR.getUrl(), 'Opportunity Id does not match in Return URL');

        List<Invoice__c> invListCheck = [SELECT Id, Amount__c, Paid__c FROM Invoice__c];   
        
        // Should still have 3 invoices (0 amount not paid would be deleted), Null amount should be overwritten to 0.
        Assert.areEqual(3, invListCheck.size(), 'Invoice List Size does not match 3.');

    }

}