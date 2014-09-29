using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using Sitecore.Configuration;
using Sitecore.Data;
using Sitecore.Data.Items;
using Sitecore.Diagnostics;
using Sitecore.Install.Framework;
using Sitecore.SecurityModel;

namespace Sitecore.SharedSource.ShellWax.Install
{
    public class PostStep : IPostStep
    {

        public void Run(ITaskOutput output, NameValueCollection metaData)
        {
            Assert.ArgumentNotNull(output, "output");
            Assert.ArgumentNotNull(metaData, "metaData");

            ConfigureShellWax(output, "master");
            ConfigureShellWax(output, "core");
        }


        private void ConfigureShellWax(ITaskOutput output, string database)
        {
            using (new SecurityDisabler())
            {
                var currentdb = Factory.GetDatabase(database, false);
                if (currentdb == null)
                {
                    output.Alert(string.Format("Database '{0}' not found. ShellWax auto-configuration will not be executed.", database));
                }
                else
                {
                    //Configuring the "Task Schedule Field Editor":
                    //1. Change the field type of the "Schedule" field on the template "/sitecore/templates/System/Tasks/Schedule" from "text" to "IFrame"
                    //2. In the field source enter: "/sitecore modules/shell/editors/TaskSchedule/TaskSchedule.aspx?field=Schedule"
                    //3. On the /sitecore/templates/System/Tasks/Schedule/Data/Schedule item, select View-->Standard Fields
                    //4. Goto the "Style" field in the "Appearance" section and add this value: "height:250px"
                    var scheduleTemplate = currentdb.GetTemplate("System/Tasks/Schedule");
                    var scheduleField = scheduleTemplate.GetField("Schedule");

                    scheduleField.BeginEdit();
                    try
                    {
                        scheduleField.Type = "IFrame";
                        scheduleField.Source = "/sitecore modules/shell/editors/TaskSchedule/TaskSchedule.aspx?field=Schedule";
                        scheduleField.Style = "height:300px";
                        scheduleField.EndEdit();
                        output.Alert("'Task Schedule Field Editor' configured successfully.");
                    }
                    catch (Exception exception)
                    {
                        scheduleField.InnerItem.Editing.CancelEdit();
                        output.Alert(string.Format("'Task Schedule Field Editor' configuration failed. Exception details: {0}", exception.ToString()));
                    }



                    //Configuring the "Execute Now!" ribbon:
                    //1. Goto the "/sitecore/templates/System/Tasks/Schedule" template in Content Editor
                    //2. In the "Configure" tab, click the "Contextual Tab" button in the "Appearance" chunk
                    //3. Choose: /content/Applications/Content Editor/Ribbons/Contextual Ribbons/Schedules

                    scheduleTemplate.BeginEdit();
                    try
                    {
                        scheduleTemplate.InnerItem.Appearance.Ribbon = "{DE9038AE-568B-4ED0-A4DF-D80BD867AD27}";
                        scheduleTemplate.EndEdit();
                        output.Alert("Task 'Execute Now!' configured successfully.");
                    }
                    catch (Exception exception)
                    {
                        scheduleTemplate.InnerItem.Editing.CancelEdit();
                        output.Alert(string.Format("Task 'Execute Now!' configuration failed. Exception details: {0}", exception.ToString()));
                    }
                }
            }
        }
    
    }
}
