'use client';
import {useState} from 'react';
const URL='https://axcdabttoxukssewrqiz.supabase.co';
const KEY='sb_publishable_JMIoyODy2E0_rkqY85kE6w_domL4Kol';
const labels={due_soon:'Vencimento em 3 dias',overdue:'Mensalidade vencida',absence:'30 dias sem presença'};
export default function App(){
const [session,S]=useState(null),[gym,G]=useState(null),[students,L]=useState([]),[payments,P]=useState([]),[rules,R]=useState([]),[events,E]=useState([]),[tab,T]=useState('Visão geral'),[message,M]=useState(''),[busy,B]=useState(false),[query,Q]=useState('');
async function api(path,method='GET',body,token=session?.access_token){const r=await fetch(URL+path,{method,headers:{apikey:KEY,Authorization:'Bearer '+(token||KEY),'Content-Type':'application/json',Prefer:'return=representation'},...(body?{body:JSON.stringify(body)}:{})});const d=await r.json().catch(()=>null);if(!r.ok)throw Error(d?.msg||d?.message||d?.error_description||'Operação não concluída');return d;}
async function run(fn){if(busy)return;B(true);M('');try{await fn()}catch(e){M(e.message)}finally{B(false)}}
async function load(g,token){const suffix='?gym_id=eq.'+g.id;const data=await Promise.all(['students','payments','automation_rules','events'].map(t=>api('/rest/v1/'+t+suffix+(t==='events'?'&order=created_at.desc&limit=100':''),'GET',null,token)));L(data[0]);P(data[1]);R(data[2]);E(data[3]);}
async function login(e){e.preventDefault();const f=new FormData(e.currentTarget),signup=e.nativeEvent.submitter.value==ֻǱ˞￿￿￿