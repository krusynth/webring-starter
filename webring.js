---
---
document.write('<div id="ctwebring"></div>');

function showWebring(useStyles) {
  let elm = 'ctwebring';

  const url = '{{ "list.json" | absolute_url }}';

  let req = new XMLHttpRequest();
  req.open('GET', url, true);
  req.responseType = 'json';

  req.onload = function() {
    if(req.status != 200) {
      console.error('Webring: Unable to load', url);
      return;
    }

    if(!req.response) {
      console.error('Webring: No response returned', url);
    }

    doShow(req.response, elm);
  }

  function doShow(response, elm) {
    let sites = response.sites;

    let current;
    for(let i = 0; i < sites.length; i++) {
      if(window.location.href.substr(0, sites[i].url.length) === sites[i].url) {
        current = i;
        break;
      }
    }

    if(typeof current === 'undefined') {
      current = 0;
    }


    let next = sites[((current + 1) % sites.length)];
    let prev = sites[((current + sites.length - 1) % sites.length)];

    document.getElementById(elm).innerHTML = `<div class="CTW-container">
      <div class="CTW-intro">
        This website is part of the <strong><a href="{{ '/' | absolute_url }}">{{ site.title }}</a></strong>.
      </div>

      <nav class="CTW-nav"><ul>
        <li class="CTW-link CTW-link-prev">
          <span class="CTW-link-direction">&larr;</span>
          <a href="${prev.url}" class="CTW-link-name">${prev.name}</a>
        </a></li>
        <li class="CTW-link CTW-link-next">
          <a href="${next.url}" class="CTW-link-name">${next.name}</a>
          <span class="CTW-link-direction">&rarr;</span>
        </a></li>
      </ul></nav>

    </div>`;

    if(useStyles) {
      let style = document.createElement('style');
      style.appendChild(document.createTextNode(`
        .CTW-intro {
          margin-bottom: 1rem;
        }

        .CTW-nav {
          list-style: none;
          display: flex;
        }
        .CTW-link {
          display: inline-block;
        }
        .CTW-link:not(:last-child) {
          margin-right: 2rem;
        }
      `));

      document.getElementById(elm).appendChild(style);

    }
  }


  req.send();
}
