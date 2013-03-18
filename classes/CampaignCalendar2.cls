/*
Marketing Calendar for Salesforce.com
FullCalendar.resource is a zip file containing the open source jquery and fullcalendar
Copyright (c) 2011 James Sullivan, Cambridge Cloud Partners
*/
public with sharing class CampaignCalendar2 {

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
    
     /*Method to search lead based on company name and the fieldset*/
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
    
    
    public class CalendarEntry{
        public Campaign campaign;
        public String className;
        public String title;
        public String url;
        public Date startDate;
        public Date endDate;
        public Boolean  allDay = true;
        public CalendarEntry(Campaign campaign){
            this.campaign = campaign;
            this.title = campaign.Name;
            this.url = '/'+campaign.Id;
            this.startDate = campaign.StartDate;
            this.endDate= campaign.endDate;

            if(campaign.Color_Status__c == null || campaign.Color_Status__c == 'null' || campaign.Color_Status__c == ''){
                campaign.Color_Status__c = 'blue';
            }
            className = 'calcolor-'+campaign.Color_Status__c.toLowerCase();
        }
    }
    

}