/*
Marketing Calendar for Salesforce.com
FullCalendar.resource is a zip file containing the open source jquery and fullcalendar
Copyright (c) 2011 James Sullivan, Cambridge Cloud Partners
*/
public with sharing class CampaignCalendar {
	public class CalendarEntry{
		private CampaignCalendar cc;
		public Campaign c {get;set;}
		public String title {get;set;}
		public String url {get;set;}
		public String color {get;set;}
		public Date startDate {get;set;}
		public Date endDate {get;set;}
		public String getStartDateYear(){return (startDate != null?''+startDate.year():'0');}
		public String getStartDateMonth(){return (startDate != null?''+(startDate.month()-1):'0');}
		public String getStartDateDay(){return (startDate != null?''+startDate.day():'0');}
		public String getEndDateYear(){return (endDate != null?''+endDate.year():'0');}
		public String getEndDateMonth(){return (endDate != null?''+(endDate.month()-1):'0');}
		public String getEndDateDay(){return (endDate != null?''+endDate.day():'0');}
		public CalendarEntry(Campaign c,CampaignCalendar cc){
			this.c = c;
			this.cc = cc;
			this.title = c.Name;
			url = '/'+c.Id;
			startDate = c.StartDate;
			endDate = c.EndDate;
			if(endDate == null)
				endDate = startDate;
			color = c.Color_Status__c;
			if(color == null || color == 'null' || color == ''){
				color = 'blue';
				c.Color_Status__c = '';
			}
			color = color.toLowerCase();
		}
	}
	
	public CalendarEntry[] displayRows {get;set;}
	public String calendarJson {get;set;}
	public Campaign[] campaigns {get;set;}
	public Boolean isTest = false;
	
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
	
	// constructor
	
	public CampaignCalendar(){
		refresh();
	}
	
	public PageReference refresh(){
		
		displayRows = new List<CalendarEntry>();
		String soql =
			'select Id,Name,StartDate,EndDate,Color_Status__c, '+
			'Owner.Name,'+
			'Status,Type, NumberOfResponses '+
			'from Campaign '+
			'where IsActive = true '+
			'and StartDate != null '+
			'and Color_Status__c != \'Hide\' ';
		if(isTest)
			soql += ' and CreatedDate = TODAY limit 100 ';
		
		campaigns = new List<Campaign>();
		for(Campaign c : Database.query(soql)){
			campaigns.add(c);
			CalendarEntry ce = new CalendarEntry(c,this);
			displayRows.add(ce);
		}
		
		return null;
	}
	
	@isTest
	public static void test1(){
		CampaignCalendar types = new CampaignCalendar(); // just to get types
		List<Campaign> campaigns = new List<Campaign>();
		for(Integer i = 0 ; i < 10 ; i++ )
			campaigns.add(
				new Campaign(
					Name = 'asdf',
					StartDate = Date.today().addDays(campaigns.size()*2),
					EndDate = Date.today().addDays(campaigns.size()*2),
					Color_Status__c = 'Red',
					Status = 'Active',
					IsActive = true
				)
			);
		insert campaigns;
		
		PageReference pr = Page.CampaignCalendar;
		pr.getParameters().put('startDate',Date.today().month()+'/'+Date.today().day()+'/'+Date.today().year());
		pr.getParameters().put('types',campaigns[0].Type);
		Test.setCurrentPage(pr);
		CampaignCalendar cc = new CampaignCalendar();
		
		cc.getColors();
		
		cc.isTest = true;
		cc.refresh();
		
		CalendarEntry validationCampaignEntry;
		for(CalendarEntry ce : cc.displayRows)
			if(ce.c.Id == campaigns[0].Id)
				validationCampaignEntry = ce;
		
		System.assertEquals(String.valueOf(Date.today().day()),validationCampaignEntry.getEndDateDay());
		System.assertEquals(String.valueOf(Date.today().month()-1),validationCampaignEntry.getEndDateMonth());
		System.assertEquals(String.valueOf(Date.today().year()),validationCampaignEntry.getEndDateYear());
		System.assertEquals(String.valueOf(Date.today().day()),validationCampaignEntry.getStartDateDay());
		System.assertEquals(String.valueOf(Date.today().month()-1),validationCampaignEntry.getStartDateMonth());
		System.assertEquals(String.valueOf(Date.today().year()),validationCampaignEntry.getStartDateYear());
		
		// test CalendarEntry replacement of nulls
		
		CalendarEntry ce = new CalendarEntry(new Campaign(),cc);
		System.assertEquals('0',ce.getEndDateDay());
		System.assertEquals('0',ce.getEndDateMonth());
		System.assertEquals('0',ce.getEndDateYear());
		System.assertEquals('0',ce.getStartDateDay());
		System.assertEquals('0',ce.getStartDateMonth());
		System.assertEquals('0',ce.getStartDateYear());
	}
}