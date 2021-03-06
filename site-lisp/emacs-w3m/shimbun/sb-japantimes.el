;;; sb-japantimes.el --- shimbun backend for www.japantimes.co.jp

;; Author: Hidetaka Iwai <tyuyu@mb6.seikyou.ne.jp>

;; Keywords: news

;;; Copyright:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 59 Temple Place, Suite 330; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Original code was nnshimbun.el written by
;; TSUCHIYA Masatoshi <tsuchiya@namazu.org>.

;;; Code:

(require 'shimbun)
(require 'sb-text)

(luna-define-class shimbun-japantimes (shimbun shimbun-text) ())

(defvar shimbun-japantimes-url "http://www.japantimes.co.jp/")
(defvar shimbun-japantimes-groups
  '("general" "business"))
(defvar shimbun-japantimes-from-address "webmaster@japantimes.co.jp")
(defvar shimbun-japantimes-content-start "\n<! ---- MAIN CONTENT AREA ---->\n")
(defvar shimbun-japantimes-content-end  "\n<! bottombarstart>\n")

(defvar shimbun-japantimes-group-path-alist
  '(("general" . "news.htm")
    ("business" . "business.htm")))
(defvar shimbun-japantimes-expiration-days 7)

(luna-define-method shimbun-index-url ((shimbun shimbun-japantimes))
  (concat (shimbun-url-internal shimbun)
	  (cdr (assoc (shimbun-current-group-internal shimbun)
		      shimbun-japantimes-group-path-alist))))

(luna-define-method shimbun-get-headers ((shimbun shimbun-japantimes)
					 &optional range)
  (let ((case-fold-search t) headers)
    (goto-char (point-min))
    (while (re-search-forward "<A HREF=\"\\(cgi-bin/getarticle.pl5\\?\\w\\w\\([0-9][0-9][0-9][0-9]\\)\\([0-1][0-9]\\)\\([0-3][0-9]\\)\\(\\w[0-9]\\).htm\\)\"><IMG BORDER=[0-9]+ HEIGHT=\"[0-9]+\" WIDTH=\"[0-9]+\" SRC=\"images/blue.gif\"> <FONT SIZE=\"[0-9]+\"><B>\\([^[<>]+\\)</B></FONT></A><BR>" nil t)
      (let* ((url (match-string 1))
	     (year (match-string 2))
	     (month (match-string 3))
	     (day (match-string 4))
	     (tag (match-string 5))
	     (subject (match-string 6))
	     id date)
	(setq id (format "<%s.%s.%s.%s%%%s@www.japantimes.co.jp>"
			 tag day month year
			 (shimbun-current-group-internal shimbun)))
	(setq date (shimbun-make-date-string
		    (string-to-number year)
		    (string-to-number month)
		    (string-to-number day)))
	(push (shimbun-make-header
	       0
	       (shimbun-mime-encode-string subject)
	       (shimbun-from-address shimbun)
	       date id "" 0 0 (concat
			       (shimbun-url-internal shimbun)
			       url))
	      headers)))
      headers))

(provide 'sb-japantimes)

;;; sb-japantimes.el ends here
