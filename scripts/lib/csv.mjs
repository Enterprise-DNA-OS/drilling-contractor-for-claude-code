// RFC-style CSV: BOM, CRLF, embedded newlines and doubled quotes.
// Preserve field text; reject malformed or duplicate headers and uneven rows.
export function parseCsv(input, { allowDuplicate = [] } = {}) {
 const text=String(input).replace(/^\uFEFF/,'');
 const rows=[];let row=[],field='',state='plain';
 const pushField=()=>{row.push(field);field='';state='plain';};
 const pushRow=()=>{pushField();rows.push(row);row=[];};
 for(let i=0;i<text.length;i++){
  const c=text[i];
  if(state==='quoted'){
   if(c==='"'){if(text[i+1]==='"'){field+='"';i++;}else state='closed';}
   else field+=c;
  }else if(c===',')pushField();
  else if(c==='\r'||c==='\n'){if(c==='\r'&&text[i+1]==='\n')i++;pushRow();}
  else if(c==='"'&&state==='plain'&&field==='')state='quoted';
  else if(state==='closed'||c==='"')throw Error('Malformed CSV: unexpected character outside quoted field');
  else field+=c;
 }
 if(state==='quoted')throw Error('Malformed CSV: unclosed quoted field');
 if(field!==''||row.length||state==='closed')pushRow();
 const nonempty=rows.filter(r=>r.some(v=>v.trim()!==''));if(!nonempty.length)return [];
 const counts=new Map();
 const header=nonempty.shift().map(h=>{h=h.trim();const key=h.toLowerCase();const n=(counts.get(key)||0)+1;counts.set(key,n);return n>1&&allowDuplicate.some(x=>x.toLowerCase()===key)?`${h} (${n})`:h;});
 if(header.some(h=>!h)||new Set(header.map(h=>h.toLowerCase())).size!==header.length)throw Error('CSV requires unique, nonempty column names');
 return nonempty.map((r,i)=>{if(r.length!==header.length)throw Error(`CSV row ${i+2}: expected ${header.length} fields, found ${r.length}`);return Object.fromEntries(header.map((h,j)=>[h,r[j]]));});
}
export function pick(row,...names){
 for(const name of names){const key=Object.keys(row).find(k=>k.toLowerCase()===name.toLowerCase());if(key!==undefined&&row[key]!=='')return row[key];}
 return '';
}
export function yesNo(v,dflt=false){const s=String(v??'').trim().toLowerCase();return s?['yes','true','y','1'].includes(s):dflt;}
