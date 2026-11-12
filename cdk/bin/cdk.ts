#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { AgroFarmStack } from '../lib/agrofarm-stack';

const app = new cdk.App();

new AgroFarmStack(app, 'AgroFarmStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    // Frankfurt: same region as the Supabase project, so every query stays in-region
    region: process.env.AWS_REGION ?? process.env.CDK_DEFAULT_REGION ?? 'eu-central-1',
  },
  budgetEmail: app.node.tryGetContext('budgetEmail') ?? process.env.BUDGET_EMAIL,
  budgetUsd: Number(app.node.tryGetContext('budgetUsd') ?? process.env.BUDGET_USD ?? 15),
  instanceType: app.node.tryGetContext('instanceType'),
  amiId: app.node.tryGetContext('amiId') || undefined,
});
