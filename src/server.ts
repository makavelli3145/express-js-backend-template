import { App } from '@/app';
import { AuthRoute } from '@routes/auth.route';
import { ValidateEnv } from '@utils/validateEnv';
import { GroupRoute } from '@routes/groups.routes';

ValidateEnv();

const app = new App([new AuthRoute(), new GroupRoute()]);

app.listen();
