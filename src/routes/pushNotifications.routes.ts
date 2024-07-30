import { Router } from 'express';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { CreatePushNotificationDto } from '@dtos/pushNotifications.dto';
import { PushNotificationsController } from '@controllers/pushNotifications.controller';
import { AuthMiddleware } from '@middlewares/auth.middleware';

export class GroupRoute implements Routes {
  public router = Router();
  public pushNotifications = new PushNotificationsController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post(
      '/pushNotifications/create',
      AuthMiddleware,
      ValidationMiddleware(CreatePushNotificationDto),
      this.pushNotifications.createPushNotification,
    );
  }
}
