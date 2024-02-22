public with sharing class AITherapist {

    public List<String> resp = new List<String>();
    public Integer msgCount = 0;

    public AITherapist() {
        resp.add('Tell me more about that.');
        resp.add('Is there anything deeper going on?');
        resp.add('What do you think might cause your persepctive to change?');
    }

    public String talk(String msg){

        String response = resp[msgCount];
        msgCount++;
        if(msgCount > resp.size() -1){
            msgCount = 0;
        } 
        
        return response;
    }

}
