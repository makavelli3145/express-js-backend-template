import { Router } from 'express';
import { UserGroupController } from '@controllers/userGroup.controller';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { CreateUserGroupDto, UpdateUserGroupDto, DeleteUserGroupDto } from '@dtos/userGroup.dto';
import { AuthMiddleware } from '@middlewares/auth.middleware';

export class UserGroupRoute implements Routes {
  public router = Router();
  private userGroup = new UserGroupController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post('/user-group/create', AuthMiddleware, ValidationMiddleware(CreateUserGroupDto), this.userGroup.createUserGroup);
    this.router.put('/user-group/update', AuthMiddleware, ValidationMiddleware(UpdateUserGroupDto), this.userGroup.updateUserGroup);
    this.router.delete('/user-group/delete', AuthMiddleware, ValidationMiddleware(DeleteUserGroupDto), this.userGroup.deleteUserGroup);
    this.router.get('/user-group/user', AuthMiddleware, this.userGroup.getGroupsByUserId);
    this.router.get('/user-group/group', AuthMiddleware, this.userGroup.getAllUsersByGroupId);
  }
}
