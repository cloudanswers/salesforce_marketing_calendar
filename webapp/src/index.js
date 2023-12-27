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
    var calendarEl = document.getElementById('calendarx');
    $('.combo').select2({width: 'resolve'});
  
    var calendar = new Calendar(calendarEl, {
      plugins: [ interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin ],
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
      },
      initialDate: '2018-01-12',
      navLinks: true, // can click day/week names to navigate views
      editable: true,
      dayMaxEvents: true, // allow "more" link when too many events
      events: [
        {
          title: 'All Day Event',
          start: '2018-01-01',
        },
        {
          title: 'Long Event',
          start: '2018-01-07',
          end: '2018-01-10'
        },
        {
          groupId: 999,
          title: 'Repeating Event',
          start: '2018-01-09T16:00:00'
        },
        {
          groupId: 999,
          title: 'Repeating Event',
          start: '2018-01-16T16:00:00'
        },
        {
          title: 'Conference',
          start: '2018-01-11',
          end: '2018-01-13'
        },
        {
          title: 'Meeting',
          start: '2018-01-12T10:30:00',
          end: '2018-01-12T12:30:00'
        },
        {
          title: 'Lunch',
          start: '2018-01-12T12:00:00'
        },
        {
          title: 'Meeting',
          start: '2018-01-12T14:30:00'
        },
        {
          title: 'Happy Hour',
          start: '2018-01-12T17:30:00'
        },
        {
          title: 'Dinner',
          start: '2018-01-12T20:00:00'
        },
        {
          title: 'Birthday Party',
          start: '2018-01-13T07:00:00'
        },
        {
          title: 'Click for Google',
          url: 'http://google.com/',
          start: '2018-01-28'
        }
      ]
    });
  
    calendar.render();
});

window.filterData = function() {
  getCalendarEntries($('#parentCampaign').val(), $('select.campaignType').val());
}

function getCalendarEntries(parentCampaignId, status){
  if (parentCampaignId == null) {
    parentCampaignId = '';
  }
  
  if (status == null) {
    status = '';
  }
  
  Visualforce.remoting.Manager.invokeAction(                    
    RemoteAction.getCalendarEntry,
    parentCampaignId,status,
    function(result, event) {
      if (event.status) {
        $.each(result, function() {
          this.start = parseStartDate(this.startDate);
          this.end = parseEndDate(this.endDate);
        });
        console.log(result);
      } else {
        alert(event.message);
      }
    },
    { escape: true }
  );
}

function parseStartDate(data){
  return moment.utc(data);
}

function parseEndDate(data){
  return moment.utc(data + 86400000);
}