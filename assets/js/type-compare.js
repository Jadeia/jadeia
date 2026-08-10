/* Temporary body-face comparison switch.
 *
 * The site ships with EB Garamond. Open any page with ?type=compare to get a
 * small switcher and flip between EB Garamond and IM Fell English while you
 * read; the choice follows you across pages until you close the panel.
 * Ordinary visitors never see it and never load the extra font work.
 *
 * To remove once the face is settled: delete this file, its <script> tag on
 * every page, the two comparison blocks in assets/css/site.css, and the
 * loser's family from each page's Google Fonts <link>.
 */
(function () {
  var KEY_ON = 'jadeia:type-compare';
  var KEY_FACE = 'jadeia:body-face';

  var store;
  try { store = window.localStorage; } catch (e) { store = null; }

  function get(k) { try { return store && store.getItem(k); } catch (e) { return null; } }
  function set(k, v) { try { store && store.setItem(k, v); } catch (e) {} }
  function drop(k) { try { store && store.removeItem(k); } catch (e) {} }

  var on = /[?&]type=compare\b/.test(window.location.search) || get(KEY_ON) === '1';
  if (!on) return;
  set(KEY_ON, '1');

  // Applied before first paint so the page does not flash the other face.
  function apply(face) {
    if (face === 'fell') document.documentElement.setAttribute('data-body-font', 'fell');
    else document.documentElement.removeAttribute('data-body-font');
  }

  var face = get(KEY_FACE) === 'fell' ? 'fell' : 'garamond';
  apply(face);

  function panel() {
    var box = document.createElement('div');
    box.className = 'typecmp';
    box.setAttribute('aria-label', 'Body face');

    var buttons = {};
    [['garamond', 'EB Garamond'], ['fell', 'IM Fell']].forEach(function (pair) {
      var b = document.createElement('button');
      b.type = 'button';
      b.textContent = pair[1];
      b.setAttribute('aria-pressed', String(face === pair[0]));
      b.addEventListener('click', function () {
        face = pair[0];
        set(KEY_FACE, face);
        apply(face);
        Object.keys(buttons).forEach(function (k) {
          buttons[k].setAttribute('aria-pressed', String(k === face));
        });
      });
      buttons[pair[0]] = b;
      box.appendChild(b);
    });

    var close = document.createElement('button');
    close.type = 'button';
    close.className = 'typecmp__close';
    close.textContent = '×';
    close.title = 'Leave comparison mode';
    close.addEventListener('click', function () {
      drop(KEY_ON);
      box.remove();
    });
    box.appendChild(close);

    document.body.appendChild(box);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', panel);
  } else {
    panel();
  }
})();
