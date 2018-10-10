/**********************************************************************
 * @Aim:Class is used as container to hold various util methods
 * @UsedAt:LookupController
 * @Company:PopcornApps
 * ********************************************************************
 * Date           Auther              Description
 * 07-07-2018     Syed Furqan Ahmed   added public method for  sending error email and check curd permission 
 * 
 */
public with Sharing class Utils {
    //define org namespace without __
    Private static final String ORGNAMESPACE = 'PA_LFM';
    public enum CURDOpration {CREATE,MODIFY,READ,REMOVE}
    /*@Aim:Check object permision along with fls
     *@Param:query that needs to be cheked
     *@Return:Boolean value for permisson
     */
    public static Boolean checkCurd(String queryOrObjectName,CURDOpration opration){
        
        queryOrObjectName=queryOrObjectName.replaceAll('select','SELECT').replaceAll('from','FROM').replaceAll('where','WHERE');
        queryOrObjectName=queryOrObjectName.replaceAll('Select','SELECT').replaceAll('From','FROM').replaceAll('Where','WHERE');
        Map<String,List<String>> allFields=formateQuery(queryOrObjectName);
         
        Boolean isAccess=true;
         for(String objectName:allFields.keySet()){
            Schema.DescribeSObjectResult objSchema=getSchema(objectName);
            if(objSchema!=null){
                if(opration==CURDOpration.CREATE){
                    if(!objSchema.isCreateable()){
                        System.debug('Does not enough permision on object '+objectName);
                       isAccess=false; 
                    }
                }
                else if(opration==CURDOpration.MODIFY){
                    if(objSchema.isUpdateable()){
                        List<String> fields=allFields.get(objectName);
                        for(String fName:fields){
                            if(!( objSchema.fields.getMap().containsKey(fName) 
                                 && 
                                 (objSchema.fields.getMap().get(fName)).getDescribe().isUpdateable()
                                )){
                                    System.debug('Does not enough permision on '+fName+' of object '+objectName);
                                    isAccess=false;
                                    break;
                            }
                        }
                    }
                    else{
                        isAccess=false;
                    }
                    
                }
                else if(opration==CURDOpration.READ){
                    if(objSchema.isAccessible()){
                        List<String> fields=allFields.get(objectName);
                        for(String fName:fields){
                            if(!(objSchema.fields.getMap().containsKey(fName) 
                                 && 
                                 (objSchema.fields.getMap().get(fName)).getDescribe().isAccessible()
                                )){
                                    System.debug('Does not enough permision on '+fName+' of object '+objectName);
                                    isAccess=false;
                                    break;
                                }
                        }
                    }
                    else{
                        isAccess=false;
                    }
                }
                else if(opration==CURDOpration.REMOVE){
                    if(!objSchema.isDeletable()){
                        System.debug('Does not enough permision on '+objectName);
                      isAccess=false;
                    }
                    
                }
                
            }
        }
        
        return isAccess;
    }
    //return schema of object
    private static Schema.DescribeSObjectResult getSchema(String objectName){
        try{
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{objectName});     
            if(descResult.size()>0){
                return descResult[0];
            }
            else{
                return null;
                
            }
        }
        catch(exception e){
            
            return null;
        }
        
        
    }
    //returns fieldnames and its object
    private static Map<String,List<String>> formateQuery(String query){
        Map<String,List<String>> validate=new  Map<String,List<String>>();
        if(query.contains('FROM')){
        Integer numberOfQuerys=query.countMatches('FROM');
        if(numberOfQuerys==1){
            String ObjectName=getObjectName(query);
            List<String> fields=getFields(query);
            validate.put(ObjectName.trim(),fields);
        }
        if(numberOfQuerys==2){
            //finding index of inner query
            Integer startIndex=query.indexOf('(');
            Integer endIndex=query.indexOf(')');
            String innerQuery=query.substring(startIndex-1, endIndex+1);
            String orignalString=query.remove(innerQuery);
            
            //geting inner query object name 
            String innerQueryObjectName=getObjectName(innerQuery);
            // geting inner query  fields
            List<String> innerQueryfields=getFields(innerQuery);
            validate.put(innerQueryObjectName.trim(),innerQueryfields);
            //geting object name 
            String ObjectName=getObjectName(orignalString);
            // geting all fields
            List<String> fields=getFields(orignalString);
            validate.put(ObjectName.trim(),fields);
        }
        if(numberOfQuerys==3){
            //finding index of inner query 
            Integer startIndex=query.lastIndexOf('(');
            Integer endIndex=query.lastIndexOf(')');
            String innerQuery=query.substring(startIndex-1, endIndex+1);
            String orignalString=query.remove(innerQuery);
            //finding index of related query
            startIndex=query.IndexOf('(');
            endIndex=query.IndexOf(')');
            String realatedQuery=orignalString.substring(startIndex-1, endIndex+1);
            //orignal query
            orignalString=orignalString.remove(realatedQuery);
            //geting object name 
            String innerQueryObjectName=getObjectName(innerQuery);
            List<String> innerQueryfields=getFields(innerQuery);
             validate.put(innerQueryObjectName.trim(),innerQueryfields);
            //geting object name 
            String relatedObjectName=getObjectName(realatedQuery);
            List<String> relatedQueryfields=getFields(realatedQuery);
             validate.put(relatedObjectName.trim(),relatedQueryfields);
            //geting object name 
            String ObjectName=getObjectName(orignalString);
            List<String> fields=getFields(orignalString);
            validate.put(ObjectName.trim(),fields);
        }
        }
        else{
            validate.put(query,new List<String>());
        }
        return validate;
    }
    //returns object Name from query
    private static String getObjectName(String query){
        String ObjectName='';
            //geting object name 
            if(query.contains('WHERE')){
                ObjectName=query.substringBetween('FROM', 'WHERE');
            }
            else{
                ObjectName=query.substringAfter('FROM');
                List<String> temp=ObjectName.split(' ');
                for(String s:temp){
                    if(!String.isEmpty(s)){
                        ObjectName=s;    
                        break;
                    }
                }
            }
        ObjectName=ObjectName.remove('(');
        ObjectName=ObjectName.remove(')');
        ObjectName=addNameSpace(ObjectName);
      
      
        return ObjectName.trim();
    }
    //if org has namespace adds it to filed
    private static String addNameSpace(String value){
        if(!String.isEmpty(ORGNAMESPACE.trim())){
            if(value.contains('__')){
                List<String> parts=value.split('__');
                if(parts.size()==2){
                    value=ORGNAMESPACE.trim()+'__'+parts.get(0).trim()+'__'+parts.get(1).trim();
                }
            }
        }
        return value;
    }
    //returns list of fields form select part of query
    private static List<String> getFields(String query){
        // geting all fields
        String filedsString=query.substringBetween('SELECT', 'FROM');
        List<String> filds=filedsString.split(',');
        List<String> temp=new List<String>();
        for(String f:filds){
            //ignoring relation ship fields as we dont know there parent object
            if(!f.contains('.') && !String.isEmpty(f)){
                temp.add(addNameSpace(f.trim()));
            }
        }
         
       
        return temp;
    }
    
    //sends email about exception to email specifed in label 
    public static void sendErrorMail(Exception e){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {System.Label.PA_LFM.AdminEmail};
        email.setToAddresses(to);
        email.setSubject('files Error '+UserInfo.getUserEmail());
        email.setHtmlBody('Error Message :'+e.getMessage()+'\n\r'+'Stack Trace :'+e.getStackTraceString()+'\n\r'+'Cause :'+e.getCause());
        try{
            if(!System.Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });    
            }
            
        }
        catch(exception ex){
            
        }
    }
    //use this method to log
    public static void log(Object o){
        //System.debug(o);
    }
    
    //get Object name by passing record id
    public static String getObjectNameById(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }
        catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }

    
}