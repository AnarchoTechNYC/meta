# Black Hat Bash Back

In this folder, you'll find stand-alone workshop materials that focus on various aspects of offensive and defensive computer network operations. Offensive ("Red Team") materials provide exercises in degrading, disrupting, or deceiving ("the three D's") the operations or operators of information systems. Defensive ("Blue Team") materials provide exercises for detecting, preventing, and remediating attacks.

The materials herein expect that you have a working familiarity with the foundations of the technologies relevant to the exercise. Nevertheless, all exercise material added here should be written in a manner that makes it accessible to people attempting to perform the exercises for the first time. If you cannot write the exercise so it is accessible to a beginner, you probably do not understand it well enough yourself.

This project is organized in the following way:

* `exercise-name` folder, containing:
    * `README.md` file, which describes the purpose of the exercise in broad strokes. Each exercise will have at least two roles, one for the attacker ("Red Team") and one for the defender ("Blue Team"). The contents of the `README.md` file should conform to a convenitonal structure, as follows:
        1. `Scenario` section, which briefly describes an example scenario in which the exercise would be relevant in the real world.
    * `Red Team` folder, containing:
        * `README.md` file, whose contents should conform to a conventional structure, described below. We recommend that, at a minimum, the `Objectives`, `Prerequisites`, `Set up`, and `Practice` sections be included.
            1. `Objectives` - a short list of achievable offensive goals, no more than three or four. (If you are trying to accomplish more than four goals in one exercise, consider the possibility that you would be better off creating two separate exercises.)
            1. `Bill of materials` - a brief overview of the files and folders contained within the folder, with short descriptions of each, used to help assure the learner that they have the complete set of materials provided by the lab's author.
            1. `Set up` - a (reasonably) exhaustive, step-by-step walkthrough for the exact steps needed to prepare for the offensive operation. This typically includes installing the required software or (pre-)configuring a given infrastructural service.
            1. `Practice` - a detailed guide, written as prose, optimized for positive educational impact and geared to accomplish the goals of the lesson. Omit steps that are intended to be "an exercise for the reader," for obvious reasons.
            1. `Discussion` - supplemental information chunked into logical sections describing additional details related to the attack scenario or its execution.
            1. `Additional references` - a curated list of named links (not merely raw URLs) that further elucidate the topic, goals, or general subject matter but that are only relevant to particularly interested readers. Avoid including links to references already linked to in prior sections.
    * `Blue Team` folder, containing:
        * `README.md` file, whose contents should conform to a conventional structure, described below. We recommend that, at a minimum, the `Objectives`, `Prerequisites`, `Set up`, and `Practice` sections be included.
            1. `Objectives` - a short list of achievable defensive goals, no more than three or four. (If you are trying to accomplish more than four goals in one exercise, consider the possibility that you would be better off creating two separate exercises.)
            1. `Bill of materials` - a brief overview of the files and folders contained within the folder, with short descriptions of each, used to help assure the learner that they have the complete set of materials provided by the lab's author.
            1. `Set up` - a (reasonably) exhaustive, step-by-step walkthrough for the exact steps needed to prepare for the offensive operation. This typically includes installing the required software or (pre-)configuring a given infrastructural service.
            1. `Practice` - a detailed guide, written as prose, optimized for positive educational impact and geared to accomplish the goals of the lesson. Omit steps that are intended to be "an exercise for the reader," for obvious reasons.
            1. `Discussion` - supplemental information chunked into logical sections describing additional details related to the attack scenario or its execution.
            1. `Additional references` - a curated list of named links (not merely raw URLs) that further elucidate the topic, goals, or general subject matter but that are only relevant to particularly interested readers. Avoid including links to references already linked to in prior sections.

Before adding exercises to this section, have a look through the other [Train the Trainers subprojects](../) to see if a similar workshop has already been created. If so, please improve that exercise/lab/workshop rather than spending (wasting?) your time duplicating our prior work.

Further, please consider the ethical implications of the exercises you add here and compose them with careful attention to the impact on the mindset of students. Less vaguely, we expect that examples or use cases described in these exercises will strictly adhere to the political and ethical leanings of our collective. We will reject or rewrite contributions that do not respect [our collective's social rules](https://github.com/AnarchoTechNYC/meta/wiki/Social-rules#be-serious-about-the-politics-no-devils-advocates) or that we deem, in our sole judgement, inappropriate for any reason. As a general rule: [punch up](https://geekfeminism.wikia.com/wiki/Punching_up), not down.

Finally, all exercises contained herein are intended for educational purposes only. It is clear that one of the most important things to know about in order to defend against being punched is to know how to throw a punch. We are showing you what a punch looks like so that you can dodge or block it, not so that you can throw it. Your actions are your own responsibility; be prepared to face the consequences of the actions you choose to take, or do not take them.
