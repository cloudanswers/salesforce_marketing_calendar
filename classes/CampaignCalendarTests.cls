@IsTest
public class CampaignCalendarTests {
	static testMethod void testController(){
        List<Campaign> campaigns = new List<Campaign>();
        for(Integer i = 0 ; i < 10 ; i++ ){
            Campaign campaign = new Campaign(
                                        Name = 'asdf',
                                        StartDate = Date.today().addDays(campaigns.size()*2),
                                        EndDate = Date.today().addDays(campaigns.size()*2),
                                        Color_Status__c = 'Red',
                                        Status = 'Active',
                                        IsActive = true
                                    );
            
            if(i > 8){
                campaign.Color_Status__c = null;
            }
            campaigns.add(campaign);
        }
        
        // different combinations to null dates
        campaigns[5].StartDate = null;
        campaigns[6].StartDate = null;
        campaigns[6].EndDate = null;
        campaigns[7].EndDate = null;
        
        insert campaigns;
        
        Test.startTest();
            CampaignCalendar cc = new CampaignCalendar();
            System.assertNotEquals(null,cc.getColors());
            System.assertEquals(campaigns.size()-2,CampaignCalendar.getCalendarEntry('','').size());
        Test.stopTest();
    }
}