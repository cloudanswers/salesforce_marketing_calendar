import { Calendar } from '@fullcalendar/core';
import interactionPlugin from '@fullcalendar/interaction';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import moment from 'moment/moment';
import $ from 'jquery';
import select2 from 'select2/dist/js/select2';
import 'select2/dist/css/select2.css';
import './index.css';

document.addEventListener('DOMContentLoaded', function() {
  // initiate full calendar
  window.calendarX = initFullCalendar();
  // initiate select fields
  $('.combo').select2({width: 'resolve'});
  // get calendar entries
  getCalendarEntries(null, null);
});

window.filterData = function() {
  getCalendarEntries($('#parentCampaign').val(), $('select.campaignType').val());
}

function initFullCalendar() {
  var calendarEl = document.getElementById('calendarx');
  var cal = new Calendar(calendarEl, {
    plugins: [ interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin ],
    headerToolbar: {
      left: 'prev,next today',
      center: 'title',
      right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
    },
    initialDate: new Date(),
    navLinks: true, // can click day/week names to navigate views
    editable: true,
    dayMaxEvents: true, // allow "more" link when too many events
  });
  cal.render();
  return cal;
}

function getCalendarEntries(parentCampaignId, status){
  if (parentCampaignId == null) {
    parentCampaignId = '';
  }
  
  if (status == null) {
    status = '';
  }

  // remove existing events
  window.calendarX.removeAllEvents();
  
  // fetch calendar entries as per filters
  Visualforce.remoting.Manager.invokeAction(                    
    RemoteAction.getCalendarEntry,
    parentCampaignId,status,
    function(result, event) {
      if (event.status) {
        $.each(result, function() {
          this.start = parseStartDate(this.startDate);
          this.end = parseEndDate(this.endDate);
        });
        window.calendarX.addEventSource(result);
        window.calendarX.render();
      } else {
        alert(event.message);
      }
    },
    { escape: true }
  );
}

function parseStartDate(data){
  return moment.utc(data).format('YYYY-MM-DD');
}

function parseEndDate(data){
  return moment.utc(data + 86400000).format('YYYY-MM-DD');
}