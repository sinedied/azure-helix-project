/*
 * Copyright 2022 Adobe. All rights reserved.
 * This file is licensed to you under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 * OF ANY KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 */

import fetch, { Request, Response } from 'node-fetch';

export async function helixWorker(context, req) {
  const url = new URL(req.url);
  url.hostname = process.env.HELIX_HOSTNAME;
  url.port = 80;

  const request = new Request(url, req);
  request.headers.set('x-forwarded-host', request.headers.get('host'));
  request.headers.set('x-byo-cdn-type', 'azure');

  console.log(`Fetching ${request.url}`);

  let res = await fetch(request);
  res = new Response(res.body, res);

  const headers = { ...res.headers.raw() };
  console.log({ headers });
  delete headers['age'];
  delete headers['x-robots-tag'];

  context.res = {
    status: res.status,
    headers: headers,
    body: await res.text(),
  };
}
