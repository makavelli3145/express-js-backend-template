import { NextFunction, Request, Response } from 'express';
import pg from '../database/index';
export const AuthMiddleware = (req: Request, res: Response, next: NextFunction) => {
  if (req.session && req.session.userId) {
    next();
  } else {
    res.status(401).json({ error: 'Unauthorized' });
  }
};

export const JoinGroupsPermissionMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const body = req.body;
  const { id, user_id, group_id, user_group_permissions, identification_string } = body;
  const values = [identification_string];

  const sql = 'SELECT COUNT(*) as cnt FROM groups  WHERE identification_string = $1';
  pg.query(sql, values, (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: 'server error' });
    } else if (result.rowCount > 0) {
      if (parseInt(result.rows[0].cnt, 10) === 1) {
        next();
      } else {
        res.status(401).json({ error: 'unauthorized group transaction' });
      }
    } else {
      res.status(501).json({ error: 'bad request' });
    }
  });
};
