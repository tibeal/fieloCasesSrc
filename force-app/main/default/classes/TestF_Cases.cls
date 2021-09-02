@isTest
public class TestF_Cases {
	@isTest
	static void testF_Cases(){
		 try{
			 Case obj = new Case();
			 //Set Fields
			 obj = (Case) FieloPLT.SObjectService.setRequiredFields(Case.sObjectType, obj);
			 insert obj;
			 //Set Fields
			 obj = (Case) FieloPLT.SObjectService.setRequiredFields(Case.sObjectType, obj);
			 update obj;
		 } catch(Exception e) {}

	}}