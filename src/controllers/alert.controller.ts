import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { Alert } from '@interfaces/alert.interface';
import { AlertService } from '@services/alert.service';

export class AlertController {
    public alertService = Container.get(AlertService);
    public createAlert = (req: Request, res: Response, next: NextFunction) => {
        try {
            const alert: Alert = req.body;
            this.alertService.createAlert(alert).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send('an alert could not be created at this time');
                }
            });
        } catch (error) {
            next(error);
        }
    };

    public deleteAlert = (req: Request, res: Response, next: NextFunction) => {
        try {
            const alert: Alert = req.body;
            this.alertService.deleteAlert(alert).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send('There was an error with deleting an alert');
                }
            });
        } catch (error) {
            next(error);
        }
    };

    public updateAlert = (req: Request, res: Response, next: NextFunction) => {
        try {
            const alert: Alert = req.body;
            this.alertService.updateAlert(alert).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send('an alert could not be updated at this time');
                }
            });
        } catch (error) {
            next(error);
        }
    };

    public getAlerts = (req: Request, res: Response, next: NextFunction) => {
        const filterBy = req.params.filterBy;
        switch (filterBy) {
            case 'userId':
                try {
                    const groupId = parseInt(req.query.groupId);
                    const userId = parseInt(req.query.userId);
                    if (userId && groupId) {
                      console.log("userId && groupId is valid, request: ", req.params)
                      this.alertService.getAlertByUserId(userId, groupId).then(result => {
                            if (result) {
                                res.status(200).json(result);
                            } else {
                                res.status(500).send('server unable to get alerts by userId and groupId');
                            }
                        });
                    } else {
                        res.status(501).send('could not getAlertByUserId');
                    }
                } catch (error) {
                    next(error);
                }
                break;
            case 'groupId':
                try {
                    const groupId = parseInt(req.query.groupId);
                    if (groupId) {
                        this.alertService.getAlertByGroupId(groupId).then(result => {
                            if (result) {
                                res.status(200).json(result);
                            } else {
                                res.status(500).send('server unable to get alerts by userId and groupId');
                            }
                        });
                    } else {
                        res.status(501).send('invalid request, query string is missing group ID value');
                    }
                } catch (error) {
                    next(error);
                }
                break;
            case 'all':
                try {
                  const user_id = req.session.userId;
                  this.alertService.getAllAlerts(user_id).then(result => {
                        if (result) {
                            res.status(200).json(result);
                        } else {
                            res.status(500).send('server unable to get alerts by userId and groupId');
                        }
                    });
                }catch (error) {
                    next(error);
                }
                break;
            default:
                res.status(500).send('There is an issue with getting alerts');
        }
    };
}
