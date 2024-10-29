import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { Group } from '@interfaces/group.interface';
import { GroupsService } from '@services/groups.service';

export class GroupController {
  public groupService = Container.get(GroupsService);
  public createGroup = (req: Request, res: Response, next: NextFunction) => {
    try {
      const group: Group = req.body;
      this.groupService.createGroup(group).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('a group could not be created at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public getGroupsByUserId = async (req: Request, res: Response, next: NextFunction) => {
    try {
      // Extracting user id from URL parameters and convert userId to number
      const userId = Number(req.query.id);
      this.groupService.getGroupsByUserId(userId).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('a group could not be created at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public deleteGroup = (req:Request, res:Response, next:NextFunction) =>{
    try{
      const group:Group = req.body;
      this.groupService.deleteGroup(group).then(result=>{
        if(result){
          res.status(200).json(result);
        }else{
          res.status(500).send('There was an error with deleting a group');
        }
      })
    }catch(error){
      next(error)
    }
  }

  public updateGroup = (req: Request, res: Response, next: NextFunction) => {
    try {
      const reqGroup: Group = req.body;
      this.groupService.updateGroup(reqGroup).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('a group could not be updated at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };
}
