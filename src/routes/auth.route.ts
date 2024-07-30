import { Router } from 'express';
import { AuthController } from '@controllers/auth.controller';
import { CreateUserDto, DeleteUserDto, LoginUserDto } from '@dtos/users.dto';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { DeleteDeviceDto } from '@dtos/device.dto';
import { AuthMiddleware } from '@middlewares/auth.middleware';

export class AuthRoute implements Routes {
  public router = Router();
  public auth = new AuthController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post('/auth/signup', ValidationMiddleware(CreateUserDto), this.auth.signUp);
    this.router.post('/auth/login', ValidationMiddleware(LoginUserDto), this.auth.logIn);
    this.router.post('/auth/deRegisterUser', AuthMiddleware, ValidationMiddleware(DeleteUserDto), this.auth.deRegisterUser);
    this.router.post('/auth/deRegisterDevice', AuthMiddleware, ValidationMiddleware(DeleteDeviceDto), this.auth.deregisterDevice);
    this.router.post('/auth/logout', AuthMiddleware, this.auth.logout);
  }
}
