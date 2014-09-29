<%@ Page Language="C#" AutoEventWireup="true" Inherits="System.Web.UI.Page" %>

<%@ Import Namespace="Sitecore.Data" %>
<%@ Import Namespace="Sitecore.Data.Items" %>
<%@ Import Namespace="Sitecore.Data.Fields" %>
<%@ Import Namespace="Sitecore.Configuration" %>
<script language="CS" runat="server">
    private Item _contextItem;
    protected Item ContextItem
    {
        get
        {
            if (_contextItem == null)
            {
                Database db = Factory.GetDatabase("master");
                _contextItem = db.GetItem(Request.Params["id"]);
            }

            if (_contextItem == null)
            {
                // if we couldnt find it in master check core                
                Database db = Factory.GetDatabase("core");
                _contextItem = db.GetItem(Request.Params["id"]);
            }
            
            return _contextItem;
        }
    }

    private bool IsMatch(Sitecore.DaysOfWeek days, Sitecore.DaysOfWeek test)
    {
        return (days & test) == test;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        //this.AddHeaderJsLink("~/sc_scripts/jquery-1.3.2.min.js");
        var recurrence = new Sitecore.Tasks.Recurrence(this.ContextItem["Schedule"]);

        dtStartDate.Value = recurrence.StartDate.ToString("MM/dd/yyyy");
        dtStartTime.Value = recurrence.StartDate.ToString("HH:mm");
        dtEndDate.Value = recurrence.EndDate.ToString("MM/dd/yyyy");
        dtEndTime.Value = recurrence.EndDate.ToString("HH:mm");

        dayS.Checked = IsMatch(recurrence.Days, Sitecore.DaysOfWeek.Sunday);
        dayM.Checked = IsMatch(recurrence.Days, Sitecore.DaysOfWeek.Monday);
        dayT.Checked = IsMatch(recurrence.Days, Sitecore.DaysOfWeek.Tuesday);
        dayW.Checked = IsMatch(recurrence.Days, Sitecore.DaysOfWeek.Wednesday);
        dayTh.Checked = IsMatch(recurrence.Days, Sitecore.DaysOfWeek.Thursday);
        dayF.Checked = IsMatch(recurrence.Days, Sitecore.DaysOfWeek.Friday);
        daySa.Checked = IsMatch(recurrence.Days, Sitecore.DaysOfWeek.Saturday);

        tsMinIntervalBetweenRuns.Value = recurrence.Interval.ToString();
    }
</script>
<html lang="en">
<head runat="server">
    <title></title>
    <link type="text/css" rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.0/themes/smoothness/jquery-ui.css" />
    <style type="text/css">
        .ui-widget
        {
            font-size: 0.7em;
        }
    </style>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>
    <script src="jquery-ui-timepicker-addon.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(function () {
            $('input.date').datepicker();
            $('input.time').timepicker();
        });

        function ToSitecoreIsoDateFormat(d) {
            var dateString = $.datepicker.formatDate('yymmddT', d);
            var timeString = $.datepicker.formatTime('HHmmss', { hour: d.getHours(), minute: d.getMinutes(), second: d.getSeconds() });
            return dateString + timeString;
        }
        function scGetFrameValue(value, request) {
            // Gather values to build the raw 'Schedule' field value
            var dtStartDate = $('#<%= dtStartDate.ClientID %>').val();
            var dtStartTime = $('#<%= dtStartTime.ClientID %>').val();
            var dtEndDate = $('#<%= dtEndDate.ClientID %>').val();
            var dtEndTime = $('#<%= dtEndTime.ClientID %>').val();
            var ts = $('#<%= tsMinIntervalBetweenRuns.ClientID %>').val();

            var start = ToSitecoreIsoDateFormat(new Date(dtStartDate + " " + dtStartTime));
            var end = ToSitecoreIsoDateFormat(new Date(dtEndDate + " " + dtEndTime));

            var dayEnum = 0;
            var days = $('input.day:checked').each(function () {
                dayEnum += parseInt($(this).val());
            });

            return start + '|' + end + '|' + dayEnum + '|' + ts;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div style="padding: 2px 2px 2px 2px; width: 400px;">
        <asp:Panel ID="pnlRawValue" runat="server" Visible="false">
            <asp:TextBox ID="txtValue" runat="server" TextMode="MultiLine" Rows="3" Columns="100"></asp:TextBox>
        </asp:Panel>
        <asp:Panel ID="pnlFieldControls" runat="server">
            <fieldset>
                <legend>Date Range</legend>
                <table border="0">
                    <tr>
                        <td>
                            From:
                        </td>
                        <td>
                            <input id="dtStartDate" runat="server" type="text" class="date" /><input id="dtStartTime"
                                runat="server" type="text" class="time" />
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align: right">
                            To:
                        </td>
                        <td>
                            <input id="dtEndDate" runat="server" runat="server" type="text" class="date" /><input
                                id="dtEndTime" runat="server" type="text" class="time" />
                        </td>
                    </tr>
                </table>
            </fieldset>
            <br />
            <fieldset>
                <legend>Days</legend>
                <input id="dayS" runat="server" class="day" type="checkbox" value="1" />Sunday
                <input id="dayM" runat="server" class="day" type="checkbox" value="2" />Monday
                <input id="dayT" runat="server" class="day" type="checkbox" value="4" />Tuesday
                <input id="dayW" runat="server" class="day" type="checkbox" value="8" />Wednesday
                <input id="dayTh" runat="server" class="day" type="checkbox" value="16" />Thursday
                <input id="dayF" runat="server" class="day" type="checkbox" value="32" />Friday
                <input id="daySa" runat="server" class="day" type="checkbox" value="64" />Saturday
            </fieldset>
            <br />
            <fieldset>
                <legend>Minimum Interval Between Runs (<a target="_blank" href="http://msdn.microsoft.com/en-us/library/se73z7b9(v=vs.100).aspx">.NET
                    TimeSpan</a>)</legend>
                <input id="tsMinIntervalBetweenRuns" runat="server" type="text" />
            </fieldset>
        </asp:Panel>
    </div>
    </form>
</body>
</html>
