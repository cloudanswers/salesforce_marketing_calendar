({
	doInit : function(helper,component) {
		var action = component.get("c.getCalendarEntryAura");
		action.setParams({"parentCampaignId":"","type" : ""});
		action.setCallback(this, function(response){
			console.log('response',response);
			if (response.getState() === "SUCCESS") {
                //component.set('v.campaigns',response.getReturnValue());
				helper.initCalendar(helper.parseEnteries(response.getReturnValue()));
				console.log(response.getReturnValue());
			}
			else{
				var error = helper.parseErrors(response.getError());
				component.set("v.errors",error);
			}
		});
		$A.enqueueAction(action);
	},
	parseCampaigns : function(campaigns){
		var enteries = [];
		for(var i =0 ;i < campaigns.length; i++){
			enteries.push({
				title : campaigns[i].Name,
				start : campaigns[i].StartDate,
				end : campaigns[i].EndDate
			});
		}
		return enteries;
	},
	parseEnteries : function(results){
		for(var i =0 ;i < results.length; i++){
			results[i].start = new Date(results[i].startDate);
			results[i].end = new Date(results[i].endDate);
		}
		return results;
	},
	initCalendar : function(calendarEntries){
		console.log(calendarEntries);
		$('#calendarX').empty();
		$('#calendarX').fullCalendar({
			editable: false,
			events: calendarEntries,
			eventClick: function(event) {
				if (event.url) {
					window.open(event.url);
					return false;
				}
			},
			eventRender: function(event, element, view){

			}
		});
	},
	toast : function(title,message){
		var toastEvent = $A.get("e.force:showToast");
		if(toastEvent){
			toastEvent.setParams({
			    "title": title,
			    "message": message
			});

			toastEvent.fire();
		}
	},
	parseErrors : function(errorObj){
		var error = [];
		for(var i = 0; i < errorObj.length > 0; i ++){
			if(errorObj[i].pageErrors){
				error = error.concat(errorObj[i].pageErrors);
			}
			console.log('error',error);
			if(errorObj[i].fieldErrors){
				for(f in errorObj[i].fieldErrors){
					error = errorObj[i].fieldErrors[f].concat(errorObj[i].pageErrors);
				}
			}
		}
		return error;
	}
})
