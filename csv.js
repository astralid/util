// Utility module for modifying csv files.
// Only works on files formatted in a specific way (e.g. ; as a separator).

// Copyright 2020 Jani Huumonen. All rights reserved.

"use strict";

Array.prototype.flat = function(){ return [].concat(...this); };
Array.prototype.flatMap = function(f){ return this.map(f).flat(); };
Array.prototype.all = function(...f){ return f.map(f=>f(this)); };
Object.prototype.entries = function(){ return Object.entries(this); };
Array.prototype.transpose = function(){ return this[0].map((_,i) => this.map(v => v[i])); };

let log= (...v)=>(console.log(...v),v);
let isObjectLiteral = v=> (!!v) && (v.constructor === Object);
let duplicates = items => items.reduce((acc, v, i, arr) => arr.indexOf(v) !== i && acc.indexOf(v) === -1 ? acc.concat(v) : acc, []);

let parseCSV = ( str, sep = ';',
	r = /\"[^]+?[^\"]\"(?!\")/g,
	w = '""',
	a = [], i = 0,
	r0 = /^\"\"$/,
	w0 = ()=>a[i++]
	) => str
		.replace( r, s=>(a.push(s),w) )
		.split( '\r\n' )
		.filter( v=>v )
		.map( l=>l
			.split( sep )
			.map( c=>c
				.replace( r0, w0 )
		));
let unparseCSV = a=>a
	.map( b=>b
		.join( ';' ) )
	.join( '\r\n' )
	+ '\r\n';

let getColIndex = function (name) {
	return this[0].indexOf(name);
};

var fs = require("fs");
let load = filename => fs
	.readFileSync(filename)
	.toString();
let save = function (filename) {
	fs.writeFileSync(
		filename,
		unparseCSV(this),
		'utf8');
	return this;
};

let selectCols = function (...names) {
	let ind = names.map( v=> this[0].indexOf(v) );
	return CSV.FromArray(this
		.map( v=>v
			.filter( (_,i)=> ind.includes(i)
	)));
};
let selectRows = function (...indices) {
	return CSV.FromArray(
		indices.map(v=>this[v])
	);
};
let filterCols = function (f) {
	let keep = this
		.slice(1)
		.transpose()
		.map( (c,i)=>(c.name=this[0][i],c) )
		.map(f);
	return CSV.FromArray(this
		.map( r=>r
			.filter( (_,i)=> keep[i] )
	));
};
let filterRows = function (f) {
	return CSV.FromArray([
		this[0],
		...this.slice(1).filter(f)
	]);
};

let CSV = (function () {
	let proto_props = {
		save,
		selectCols,
		selectRows,
		filterCols,
		filterRows
	};
	let proto = Object.create(Object.assign( [], proto_props ));
	let FromArray = array => {
		array.__proto__ = proto;
		return array;
	};
	let FromFile = filename =>
		FromArray(parseCSV(load(filename)));

	return {
		FromArray,
		FromFile,
		load: fn=>parseCSV(load(fn),',')
	};
})();

module.exports = CSV;

