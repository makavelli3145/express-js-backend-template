import { App } from '@/app';
import { AuthRoute } from '@routes/auth.route';
import { ValidateEnv } from '@utils/validateEnv';
import { GroupRoute } from '@routes/groups.routes';
import { UserGroupRoute } from '@routes/userGroup.routes';
import { InitCronJobs } from '@/cron/index.cron';
import { AlertRoute } from '@routes/alerts.routes';

ValidateEnv();

const initCronJobs = new InitCronJobs();

const cronJobs = initCronJobs.initializeJobs();

const app = new App([new AuthRoute(), new GroupRoute(), new UserGroupRoute(), new AlertRoute()] /*, cronJobs*/);

try {
  app.listen();
} catch (e) {
  console.error(e);
}
