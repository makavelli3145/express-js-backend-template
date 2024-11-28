import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { UserGroupService } from '@services/userGroup.service';
import { UserGroup, JoinUserGroup } from '@interfaces/userGroup.interface';

export class UserGroupController {
    private userGroupService = Container.get(UserGroupService);

    public getUserGroupsByGroupId = async (req: Request, res: Response, next: NextFunction) => {
        try {
            // Extracting user id from URL parameters and convert userId to number
            const groupId = Number(req.query.id);
            const user_id = req.session.userId;
            this.userGroupService.getUserGroupsByGroupId(groupId, user_id).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send(`users could not be found for group with id: ${groupId}`);
                }
            });
        } catch (error) {
            next(error);
        }
    };

    public getUserGroupsByUserId = async (req: Request, res: Response, next: NextFunction) => {
        try {
            // Extracting user id from URL parameters and convert userId to number
            const requestUserId = Number(req.query.id);
            // const user_id = req.session.userId;
            this.userGroupService.getUserGroupsByUserId(requestUserId).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send(`users-groups could not be found for group with id: ${requestUserId}`);
                }
            });
        } catch (error) {
            next(error);
        }
    };

    public createUserGroup = (req: Request, res: Response, next: NextFunction) => {
        try {
            const reqUserGroup: UserGroup = req.body;
            this.userGroupService.createUserGroup(reqUserGroup).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send('cannot create a group at this point');
                }
            });
        } catch (error) {
            next(error);
        }
    };

    public updateUserGroup = (req: Request, res: Response, next: NextFunction) => {
        const reqUserGroup = req.body;
        try {
            this.userGroupService.updateUserGroup(reqUserGroup).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send('Failed to update userGroup');
                }
            });
        } catch (err) {
            next(err);
        }
    };

    public deleteUserGroup = (req: Request, res: Response, next: NextFunction) => {
        try {
            const reqUserGroup: UserGroup = req.body;
            this.userGroupService.deleteUserGroup(reqUserGroup).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send('Could not delete users group');
                }
            });
        } catch (error) {
            next(error);
        }
    };

    public JoinUserGroup = (req: Request, res: Response, next: NextFunction) => {
        try {
            const joinUserGroup: JoinUserGroup = req.body;
            this.userGroupService.joinUserGroup(joinUserGroup).then(result => {
                if (result) {
                    res.status(200).json(result);
                } else {
                    res.status(500).send('Error creating user group');
                }
            });
        } catch (error) {
            next(error);
        }
    };
}
