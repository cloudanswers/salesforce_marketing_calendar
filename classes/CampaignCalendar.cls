/*
Marketing Calendar for Salesforce.com
FullCalendar.resource is a zip file containing the open source jquery and fullcalendar
Copyright (c) 2011 James Sullivan, Cambridge Cloud Partners
*/
public with sharing class CampaignCalendar {
    public class CalendarEntry{
        public Campaign campaign;
        public String className;
        public String title;
        public String url;
        /*
        public String startDate;
        public String endDate;
        */
        public Date startDate;
        public Date endDate;
        public Boolean  allDay = true;
        public CalendarEntry(Campaign campaign){
            this.campaign = campaign;
            this.title = campaign.Name;
            this.url = '/'+campaign.Id;
            /*
            // Date() in javascript is datetime, so just passing date means it ends up in yesterday (when you're in american time zones)
            if(this.campaign.StartDate != null)
                this.startDate = '' + this.campaign.StartDate.year() + '-' + this.campaign.StartDate.month() + '-' + this.campaign.StartDate.day();
            if(this.campaign.EndDate != null)
                this.endDate = '' + this.campaign.EndDate.year() + '-' + this.campaign.EndDate.month() + '-' + this.campaign.EndDate.day();
            */
            TimeZone tz = UserInfo.getTimeZone();
            this.startDate = this.campaign.StartDate;
            this.endDate = this.campaign.endDate;
            if(campaign.Color_Status__c == null || campaign.Color_Status__c == 'null' || campaign.Color_Status__c == ''){
                campaign.Color_Status__c = 'blue';
            }
            className = 'calcolor-'+campaign.Color_Status__c.toLowerCase();
        }
    }
    
    // taken from w3c web colors
    public static final Map<String,String> colors = new Map<String,String>{
        'maroon' => 'white',
        'purple' => 'white',
        'green' => 'white',
        'teal' => 'white',
        'navy' => 'white',
        'black' => 'white',
        'blue' => 'white',
        'olive' => 'white',
        'gray' => 'white',
        
        'orange' => 'black',
        'red' => 'black',
        'fuchsia' => 'black',
        'yellow' => 'black',
        'white' => 'black',
        'silver' => 'black',
        'lime' => 'black',
        'aqua' => 'black'
    };
    public class Color{
        public String bg {get;set;}
        public String fg {get;set;}
        public Color(String bg,String fg){
            this.bg = bg;
            this.fg = fg;
        }
    }
    public List<Color> getColors(){
        List<Color> displayColors = new List<Color>();
        for(String bgcolor : colors.keySet())
            displayColors.add( new Color(bgcolor,colors.get(bgcolor)) );
        return displayColors;
    }
        

    
    @RemoteAction
    public static List<CalendarEntry> getCalendarEntry(){
         List<CalendarEntry> calendarEntries =  new List<CalendarEntry>();
         List<Campaign> campaigns = queryCampaign(
                                                     new Set<String>{
                                                                         'Name',
                                                                         'StartDate',
                                                                         'EndDate',
                                                                         'color_status__c',
                                                                         'Owner.Name',
                                                                         'Status',
                                                                         'Type',
                                                                         'NumberOfResponses'
                                                                     }
                                                     ,'IsActive = true AND StartDate != null AND Color_Status__c != \'Hide\''
                                                 );
         for(Campaign c : campaigns){
            calendarEntries.add(new CalendarEntry(c));
         }
         
         return calendarEntries;
    }
    
   
    private static List<Campaign> queryCampaign(Set<String> additionalFields,String whereClause ) {
        Set<String> fields = new Set<String>{'id'};
        String query = 'SELECT Id';
        
        for(String fs : additionalFields){
            if(!fields.contains(fs) && !fields.contains(fs.toLowerCase())){
                fs = fs.toLowerCase();
                fields.add(fs);
                query = query+','+fs;
            }
        }
        
        for(Schema.FieldSetMember f : SObjectType.Campaign.FieldSets.marketing_cal__MarketingCalendarPopup.getFields()) {
            if(!fields.contains(f.getFieldPath().toLowerCase())){
                query = query+','+f.getFieldPath().toLowerCase();
            }
        }
        query = query + ' FROM Campaign';
        query = (whereClause !=null && whereClause!='') ? query +' WHERE ' +whereClause : query;
        return Database.query(query);
    }
    
   
    
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
            System.assertEquals(campaigns.size()-2,CampaignCalendar.getCalendarEntry().size());
        Test.stopTest();
    }
    

}