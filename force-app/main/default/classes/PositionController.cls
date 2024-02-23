public class PositionController {
    public List<Position__c> getPositions() {
        return [SELECT Id, Name, Description__c FROM Position__c WHERE Status__c = 'Open'];
    }
}