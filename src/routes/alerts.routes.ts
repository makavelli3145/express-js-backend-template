import { Router } from 'express';
import { AlertController } from '@controllers/alert.controller';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { CreateAlertDto, UpdateAlertDto, DeleteAlertDto, CreateAlertSeenByDto, CreateAlertRespondingByDto } from '@dtos/alert.dto';
import { AuthMiddleware } from '@middlewares/auth.middleware';

export class AlertRoute implements Routes {
  public router = Router();
  private Alert = new AlertController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post('/alerts/create', AuthMiddleware, ValidationMiddleware(CreateAlertDto), this.Alert.createAlert);
    this.router.post('/alerts/createAlertRespondedBy', AuthMiddleware, ValidationMiddleware(CreateAlertRespondingByDto), this.Alert.createAlertRespondedBy);
    this.router.post('/alerts/createAlertSeenBy', AuthMiddleware, ValidationMiddleware(CreateAlertSeenByDto), this.Alert.createAlertSeenBy);
    this.router.put('/alerts/update', AuthMiddleware, ValidationMiddleware(UpdateAlertDto), this.Alert.updateAlert);
    this.router.delete('/alerts/delete', AuthMiddleware, ValidationMiddleware(DeleteAlertDto), this.Alert.deleteAlert);
    this.router.get('/alerts/:filterBy', AuthMiddleware, this.Alert.getAlerts);
  }
}
