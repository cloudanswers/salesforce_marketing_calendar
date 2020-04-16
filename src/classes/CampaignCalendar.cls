/*
Marketing Calendar for Salesforce.com
FullCalendar.resource is a zip file containing the open source jquery and fullcalendar
Copyright (c) 2011 James Sullivan, Cambridge Cloud Partners
*/
public with sharing class CampaignCalendar {
    public Campaign campaignObj{get;set;}
    private static String titleFieldAPI;    //variable to cache the api name of the title field
    
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
            this.title = getCalendarTitleFieldValue(campaign);
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
            this.endDate = this.campaign.endDate == NULL ? this.campaign.StartDate : this.campaign.endDate;
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
        'deepskyblue' => 'white',        
        'darksalmon' => 'white',        
        'forestgreen' => 'white',
        'palvioletred' => 'white',        
        'powederblue' => 'white',
        'tomato' => 'white',
        'saddlebrown' => 'white',        
                
        'moccasin' => 'black',
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
        
    public List<SelectOption> getActiveParentCampaigns(){
        List<SelectOption> SelectOptions = new List<SelectOption>();
        SelectOptions.add(new SelectOption('', '--None--'));
        Set<Id> campaignSet = new Set<Id>();
        
        for(AggregateResult ar : [SELECT ParentId,Count(Id)recordCount FROM Campaign WHERE ParentId !=NULL AND isActive=TRUE WITH SECURITY_ENFORCED GROUP BY ParentId]){
            if(ar.get('recordCount') != NULL && Integer.valueOf(ar.get('recordCount')) > 0){
                campaignSet.add((Id)ar.get('ParentId'));
            }
        }
        
        for(Campaign cn : [SELECT Id,Name FROM Campaign WHERE Id=:campaignSet WITH SECURITY_ENFORCED  ORDER BY Name]){
            SelectOptions.add(new SelectOption(cn.Id, cn.Name));
        }
        return SelectOptions;
    }
    
    @RemoteAction
    public static List<CalendarEntry> getCalendarEntry(String parentCampaignId, String type) {
        
        String whereClause = ' IsActive = true AND StartDate != null AND Color_Status__c != \'Hide\' ';
        
        if (String.isNotBlank(parentCampaignId)) {
            whereClause += ' AND ParentId = :parentCampaignId ';
        }
        
        if (String.isNotBlank(type)) {
            whereClause += ' AND Type = :type ';
        }
        
        String query = 'SELECT ' + String.join(queryFields(), ',') + ' FROM Campaign WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
        List<Campaign> campaigns = (List<Campaign>)Database.query(query);
        
        List<CalendarEntry> calendarEntries =  new List<CalendarEntry>();
        for(Campaign c : campaigns){
            calendarEntries.add(new CalendarEntry(c));
        } 
        return calendarEntries;
    }
    
    private static List<String> queryFields () {
        Set<String> fields = new Set<String>{
            'id', 
            'name',
            'startdate',
            'enddate',
            'color_status__c',
            'owner.name',
            'status',
            'type',
            'numberofresponses'
        };
		
        for(Schema.FieldSetMember f : SObjectType.Campaign.FieldSets.marketing_cal__MarketingCalendarPopup.getFields()) {
            fields.add(f.getFieldPath().toLowerCase());
        }
        
        for(Schema.FieldSetMember f : SObjectType.Campaign.FieldSets.marketing_cal__MarketingCalendarEventTitle.getFields()) {
            fields.add(f.getFieldPath().toLowerCase());
        }
        
        return new List<String>(fields);
    }
    
    private static String getCalendarTitleFieldValue(Campaign c){
       
        if(titleFieldAPI == NULL){
            for(Schema.FieldSetMember f : SObjectType.Campaign.FieldSets.marketing_cal__MarketingCalendarEventTitle.getFields()) {
                titleFieldAPI = f.getFieldPath();
                break; //take the first field
            }
        }
        
        if(titleFieldAPI == NULL){
            titleFieldAPI = 'Name';
        }
        
        return String.valueOf(c.get(titleFieldAPI));
    }

}