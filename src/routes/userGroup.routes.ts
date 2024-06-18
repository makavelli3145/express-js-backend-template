import { Router } from 'express';
import { UserGroupController } from '@controllers/userGroup.controller';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import {CreateUserGroupDto, UpdateUserGroupDto} from '@dtos/userGroup.dto';

export class UserGroupRoute implements Routes {
  public router = Router();
  public userGroup = new UserGroupController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post('/user-group/create', ValidationMiddleware(CreateUserGroupDto), this.userGroup.createUserGroup);
    this.router.put('/user-group/update', ValidationMiddleware(UpdateUserGroupDto), this.userGroup.updateUserGroup);
  }
}
