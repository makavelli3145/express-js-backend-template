import { Router } from 'express';
import { GroupController } from '@controllers/group.controller';
import { CreateGroupDto, UpdateGroupDto, DeleteGroupDto } from '@dtos/group.dto';
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
    this.router.post('/groups/delete', ValidationMiddleware(DeleteGroupDto), this.group.deleteGroup);
    this.router.patch('/groups/update', ValidationMiddleware(UpdateGroupDto), this.group.updateGroup);
  }
}
