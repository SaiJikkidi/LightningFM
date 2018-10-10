public class RelatedContactsController {
    Public List<contact> RelatedContactsController(ApexPages.StandardController controller){
        
      List<contact> results = Database.Query('SELECT Id,Name FROM Contact Limit 10');
       
       return results;
    }
    
   Public List<contact> getRelatedContacts(){
        
      List<contact> results = Database.Query('SELECT Id,Name FROM Contact Limit 10');
       
       return results;
    }

}