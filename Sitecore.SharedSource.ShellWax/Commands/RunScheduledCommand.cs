using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Sitecore.Shell.Framework.Commands;
using System.Collections.Specialized;
using Sitecore.Web.UI.Sheer;
using Sitecore.Diagnostics;
using Sitecore.Data.Items;
using Sitecore.Globalization;
using Sitecore.Tasks;
using Sitecore.Jobs;
using Sitecore.Shell.Framework.Jobs;

namespace Sitecore.SharedSource.ShellWax.Commands
{
    public class RunScheduledCommand : Command
    {

        public override void Execute(CommandContext context)
        {
            if (context.Items.Length == 1)
            {
                var item = context.Items[0];
                var schedule = new ScheduleItem(item);

                Sitecore.Shell.Applications.Dialogs.ProgressBoxes.ProgressBox.Execute(
                                    "Running scheduled command: " + item.Paths.Path,
                                    "Running scheduled command: " + item.Paths.Path,
                                    new Sitecore.Shell.Applications.Dialogs.ProgressBoxes.ProgressBoxMethod(RunSchedule), new object[] { schedule });
            }
        }

        public override CommandState QueryState(CommandContext context)
        {
            if (context.Items.Length != 1)
            {
                return CommandState.Hidden;
            }
            return base.QueryState(context);
        }

        protected void RunSchedule(params object[] parameters)
        {
            var schedule = parameters[0] as ScheduleItem;
            if (schedule == null)
                throw new Exception("Schedule item not found: " + schedule.InnerItem.Paths.Path);
            else
            {
                Log.Audit(this, "Run scheduled command: {0}", new string[] { AuditFormatter.FormatItem(schedule.InnerItem) });
                JobMessage("Run scheduled command: " + schedule.InnerItem.Paths.Path);
                schedule.Execute();
                JobMessage("Finished.");
            }
        }

        private static void JobMessage(string message)
        {
            if (Sitecore.Context.Job != null)
                Sitecore.Context.Job.Status.Messages.Add(message);
        }

    }
}
