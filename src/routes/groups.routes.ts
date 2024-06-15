import { Router } from 'express';
import { GroupController } from '@controllers/group.controller';
import { CreateGroupDto } from '@dtos/group.dto';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';

export class GroupRoute implements Routes {
  public router = Router();
  public group = new GroupController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post('/groups/create', ValidationMiddleware(CreateGroupDto), this.group.createGroup);
  }
}
