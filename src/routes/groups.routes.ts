import { Router } from 'express';
import { GroupController } from '@controllers/group.controller';
import { CreateGroupDto, UpdateGroupDto, DeleteGroupDto } from '@dtos/group.dto';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { AuthMiddleware } from '@middlewares/auth.middleware';

export class GroupRoute implements Routes {
  public router = Router();
  public group = new GroupController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post('/groups/create', AuthMiddleware, ValidationMiddleware(CreateGroupDto), this.group.createGroup);
    this.router.delete('/groups/delete', AuthMiddleware, ValidationMiddleware(DeleteGroupDto), this.group.deleteGroup);
    this.router.put('/groups/update', AuthMiddleware, ValidationMiddleware(UpdateGroupDto), this.group.updateGroup);
  }
}
