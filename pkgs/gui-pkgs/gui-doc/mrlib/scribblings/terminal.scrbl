#lang scribble/doc
@(require "common.rkt" 
          (for-label mrlib/terminal string-constants))

@title{Terminal Window}

@defmodule[mrlib/terminal]{The @racketmodname[mrlib/terminal] library provides
a simple GUI wrapper around functions that normally would run
in command-line scripts.}

@defproc[(in-terminal [doit (-> eventspace? 
                                (or/c (is-a?/c top-level-window<%>) #f) 
                                void?)]
                      [#:container container (or/c #f (is-a?/c area-container<%>)) #f]
                      [#:cleanup-thunk cleanup-thunk (-> void?) void]
                      [#:title title string? "mrlib/terminal"]
                      [#:abort-label abort-label string? (string-constant plt-installer-abort-installation)]
                      [#:aborted-message aborted-message string? (string-constant plt-installer-aborted)]
                      [#:canvas-min-width canvas-min-width (or/c #f (integer-in 0 10000)) #f]
                      [#:canvas-min-height canvas-min-height (or/c #f (integer-in 0 10000)) #f]
                      [#:close-button? close-button? boolean? #t]
                      [#:close-label close-label string? (string-constant close)])
         (is-a?/c terminal<%>)]{
                
  Creates a GUI, sets up the current error and output ports to
  print into the GUI's content,
  and calls @racket[doit] in a separate thread under a separate
  custodian. The @racket[exit-handler] is set to a function that
  shuts down the new custodian.

  The GUI is created in a new @racket[frame%], unless
  @racket[container] is not @racket[#f], in which case the GUI is
  created as a new panel inside @racket[container]. If a frame is
  created, it is provided as the second argument to @racket[doit],
  otherwise the second argument to @racket[doit] is @racket[#f].
  If a frame is created, its title is @racket[title].

  The result of @racket[in-terminal] is a @racket[terminal<%>] object
  that reports on the state of the terminal; this result is produced
  just after @racket[doit] is started.

  The @racket[cleanup-thunk] is called on a queued callback to the
  eventspace active when @racket[with-installer-window] is invoked
  after @racket[doit] completes.
  
  In addition to the I/O generated by @racket[doit], the generated GUI
  contains two buttons: the abort button (with label
  @racket[abort-label]) and the close button (with label
  @racket[close-label]). The close button is present only
  if @racket[close-button?] is @racket[#t].
 
  When the abort button is pushed,
  the newly created custodian is shut down and the
  @racket[aborted-message] is printed in the dialog. The close button
  becomes active when @racket[doit] returns or when the thread running
  it is killed (via a custodian shut down, typically).

  If @racket[container] is @racket[#f], then the close button closes
  the frame; otherwise, the close button causes the container created
  for the terminal's GUI to be removed from its parent.
  
  The @racket[canvas-min-width] and @racket[canvas-min-height] are passed
  to the @racket[_min-width] and @racket[_min-height] initialization arguments
  of the @racket[editor-canvas%] object that holds the output generated
  by @racket[doit].
  
  The value of @racket[on-terminal-run] is invoked after @racket[doit]
  returns, but not if it is aborted or an exception is raised.
}

@defparam[on-terminal-run run (-> void?)]{
  Invoked by @racket[in-terminal].                                          
}

@definterface[terminal<%> ()]{

The interface of a terminal status and control object produced by
@racket[in-terminal].

@defmethod[(is-closed?) boolean?]{

Returns @racket[#t] if the terminal GUI has been closed, @racket[#f]
otherwise.}

@defmethod[(close) void?]{

Closes the terminal GUI. Call this method only if @method[terminal<%>
can-close?]  returns @racket[#t].}

@defmethod[(can-close?) boolean?]{

Reports whether the terminal GUI can be closed, because the terminal
process is complete (or, equivalently, whether the close button is
enabled).}

@defmethod[(can-close-evt) evt?]{

Returns a synchronizable event that becomes ready for synchronization
when the terminal GUI can be closed.}

@defmethod[(get-button-panel) (is-a?/c horizontal-panel%)]{

Returns a panel that contains the abort and close buttons.}
}
