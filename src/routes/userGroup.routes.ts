import { Router } from 'express';
import { UserGroupController } from '@controllers/userGroup.controller';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { CreateUserGroupDto, UpdateUserGroupDto, DeleteUserGroupDto, JoinUserGroupDto } from '@dtos/userGroup.dto';
import { AuthMiddleware, JoinGroupsPermissionMiddleware } from '@middlewares/auth.middleware';

export class UserGroupRoute implements Routes {
  public router = Router();
  private userGroup = new UserGroupController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post('/user-group/create', AuthMiddleware, ValidationMiddleware(CreateUserGroupDto), this.userGroup.createUserGroup);
    this.router.post(
      '/user-group/join',
      AuthMiddleware,
      ValidationMiddleware(JoinUserGroupDto),
      JoinGroupsPermissionMiddleware,
      this.userGroup.JoinUserGroup,
    );
    this.router.put('/user-group/update', AuthMiddleware, ValidationMiddleware(UpdateUserGroupDto), this.userGroup.updateUserGroup);
    this.router.delete('/user-group/delete', AuthMiddleware, ValidationMiddleware(DeleteUserGroupDto), this.userGroup.deleteUserGroup);
    this.router.get('/user-group/group', AuthMiddleware, this.userGroup.getUserGroupsByGroupId);
    this.router.get('/user-group/user', AuthMiddleware, this.userGroup.getUserGroupsByUserId);
  }
}
