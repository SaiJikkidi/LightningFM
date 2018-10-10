public class items {
    @AuraEnabled  
    public string label { get; set; }  
    
    @AuraEnabled  
    public string name { get; set; }  
    
    @AuraEnabled  
    public string iconName { get; set; } 
    
        
    @AuraEnabled  
    public string contentfolderid { get; set; }
    
    @AuraEnabled  
    public Boolean expanded { get; set; }  
    
    @AuraEnabled  
    public List<items> items { get; set; }  
    
    public items( String name, String label, Boolean expanded, List<items> items) {  
        this.label = label;  
        this.name = name;  
        this.expanded = expanded;  
        this.items = items;   
    } 
    public items( String name, String label, Boolean expanded, List<items> items,String iconName) {  
        this.label = label;  
        this.name = name;  
        this.expanded = expanded;  
        this.items = items;
        this.iconName = iconName;
    } 
      public items( String name, String label, Boolean expanded, List<items> items,String iconName,String contentfolderid) {  
        this.label = label;  
        this.name = name;  
        this.expanded = expanded;  
        this.items = items;
        this.iconName = iconName;
          this.contentfolderid = contentfolderid;
    } 
}