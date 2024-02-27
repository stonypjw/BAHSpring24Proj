public class PositionDetailController {
    private Position__c position;

    public String firstName {get; set;}
    public String lastName {get;set;}
    public String email {get;set;}

    public PositionDetailController(ApexPages.StandardController controller) {
        this.position = (Position__c)controller.getRecord();
    }
    
    public PageReference apply() {
        // Find umbrella account
        Account a = [SELECT ID FROM Account WHERE Name = 'Account to store All Candidates' LIMIT 1];
        //Create Contact
        Contact newCandidate = new Contact();
            newCandidate.FirstName = firstName;
            newCandidate.LastName = lastName;
            newCandidate.Email = email;
            newCandidate.AccountId = a.Id;
        insert newCandidate;

        //Create application
        Application__c newApp = new Application__c();
            newApp.Position__c = position.Id;
            newApp.Candidate__c = newCandidate.Id;
        insert newApp;

        return new PageReference('/apex/availablePositions');
    }
}
