@isTest
public class PostInstallClassTEST{
    
    @isTest
    static void testScript(){
        PostInstallClass postinstall = new PostInstallClass();
        Test.testInstall(postinstall, null);
        List<ContentWorkspace> cw=[SELECT id,Name FROM ContentWorkspace];
        System.assertEquals(cw.size()>0 == true,true);

        //System.assert(cw.size()>0);
      
        //Test.testInstall(postinstall, new Version(1,0), true);
    }
}